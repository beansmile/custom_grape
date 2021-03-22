# frozen_string_literal: true

module Bean
  class Payment < ApplicationRecord
    # constants

    # concerns
    include AASM
    include AasmExtendConcern
    include Bean::NumberGenerator.new(prefix: "P", length: 18)

    # attr related macros
    enum state: {
      pending: 0,
      completed: 1,
      failure: 2,
      closed: 3
    }

    enum payment_type: {
      charge: 0,
      refund: 1
    }, _suffix: true

    # association macros
    belongs_to :payment_method, class_name: "Bean::PaymentMethod"
    belongs_to :order, class_name: "Bean::Order"
    belongs_to :paymentable, polymorphic: true
    belongs_to :parent, class_name: "Bean::Payment", optional: true

    # validation macros

    # callbacks
    after_create :increment_parent_refunding_amount!, if: :refund_payment_type?

    # other macros
    aasm column: :state, enum: true, requires_lock: true  do
      state :pending, initial: true
      state :completed
      state :failure
      state :closed

      event :complete_charge, guard: :charge_payment_type? do
        transitions from: :pending, to: :completed
      end

      event :close_charge, guard: :charge_payment_type?, after: [:request_to_close!] do
        transitions from: :pending, to: :closed
      end

      event :complete_refund, guard: :refund_payment_type?, after: [:increment_parent_refunded_amount!, :decrement_parent_refunding_amount!, :change_order_refund_amount_and_state] do
        transitions from: :pending, to: :completed
      end

      event :fail_refund, guard: :refund_payment_type?, after: [:decrement_parent_refunding_amount!] do
        transitions from: :pending, to: :failure
      end
    end

    # scopes

    # class methods

    # instance methods
    # TODO 目前只支持微信支付，后面最好改成STI
    def handle_pay_notify(result)
      db_and_redis_transaction do
        with_lock do
          update(response: result)

          if may_complete_charge?
            # 实际支付金额小于订单需要支付金额是不符合预期的，先抛出异常人工查看
            raise "用户支付金额不等于订单需要支付的金额" if amount != order.total

            complete_charge!

            order.update(completed_at: result["time_end"].in_time_zone(Time.zone.name)) if order.pay!
          end
        end
      end
    end

    def handle_refund_notify(result)
      db_and_redis_transaction do
        with_lock do
          update(response: result)

          if result["refund_status"] == "SUCCESS"
            complete_refund! if may_complete_refund?
          else
            fail_refund! if may_fail_refund?
          end
        end
      end
    end

    def request_to_close!
      payment_method_configuration = payment_method.configuration

      resp = WxPay::Service.invoke_closeorder({ out_trade_no: number }, appid: payment_method_configuration["appid"], mch_id: payment_method_configuration["mch_id"], key: payment_method_configuration["mch_key"])

      raise resp["return_msg"] unless resp["return_code"] == "SUCCESS"

      if resp["result_code"] == "FAIL"
        case resp["err_code"]
        when "ORDERPAID"
          raise "订单已支付"
        else
          raise resp["err_code_des"]
        end
      end
    end

    def refund!
      # 退款失败会抛出exception让开发查看是什么原因导致的，所以检测到payment已经是failure则直接继续抛出异常直到人工处理好
      raise "申请退款失败: #{response["err_code_des"]}" if failure?

      payment_method_configuration = payment_method.configuration
      refund_params = {
        out_trade_no: parent.number,
        out_refund_no: number,
        total_fee: (parent.amount * 100).to_i,
        refund_fee: (amount * 100).to_i,
        notify_url: "#{Rails.application.credentials.dig(Rails.env.to_sym, :host)}/orders/refund_notify"
      }

      pkcs12 = OpenSSL::PKCS12.new(File.read(payment_method.apiclient_cert.path), payment_method_configuration["mch_id"])

      resp = WxPay::Service.invoke_refund(
        refund_params,
        appid: payment_method_configuration["appid"],
        mch_id: payment_method_configuration["mch_id"],
        key: payment_method_configuration["mch_key"],
        apiclient_cert: pkcs12.certificate,
        apiclient_key: pkcs12.key
      )

      raise resp["return_msg"] unless resp["return_code"] == "SUCCESS"

      db_and_redis_transaction do
        update!(response: resp)

        fail_refund! unless resp["result_code"] == "SUCCESS"
      end

      raise "申请退款失败: #{resp["err_code_des"]}" unless resp["result_code"] == "SUCCESS"
    end

    def can_refund_amount
      @can_refund_amount = if charge_payment_type?
                             amount - refunding_amount - refunded_amount
                           else
                             0
                           end
    end

    def enqueue_refund_job(need_to_refund_amount: nil)
      db_and_redis_transaction do
        refund_payment = self.class.create(order_id: order_id, payment_method_id: payment_method_id, paymentable: paymentable, parent: self, amount: need_to_refund_amount || can_refund_amount, payment_type: :refund)

        Bean::RefundPaymentJob.perform_later(refund_payment)
      end
    end

    protected
    def increment_parent_refunding_amount!
      parent.increment!(:refunding_amount, amount) if pending?
    end

    def decrement_parent_refunding_amount!
      parent.decrement!(:refunding_amount, amount)
    end

    def increment_parent_refunded_amount!
      parent.increment!(:refunded_amount, amount)
    end

    def change_order_refund_amount_and_state
      order.increment!(:refund_amount, amount)
      order.perform_aasm_event(:cancel)
    end
  end
end
