# frozen_string_literal: true

module Bean
  class PaymentMethod::Wechat < PaymentMethod

    attr_accessor :payment

    ["mch_id" ,"mch_key" ].each do |p_attr|
      define_method p_attr do
        @p_attr = configuration[p_attr]
      end
    end

    def order
      @order ||= payment.order
    end

    def appid
      @appid ||= application.wechat_application&.appid
    end

    def process(payment)
      self.payment = payment
      if unifiedorder.success?
        pay_params = {
          prepayid: unifiedorder[:raw]["xml"]["prepay_id"],
          noncestr: unifiedorder[:raw]["xml"]["nonce_str"]
        }
        result = WxPay::Service.generate_js_pay_req pay_params, mch_account.dup
        { status: "success", data: result }
      else
        WxPay.logger.error("unifiedorder err: #{unifiedorder}")
        { status: "fail", msg: unifiedorder[:raw]["xml"]["return_msg"] }
      end
    end

    # private

    # official document for detailed request params and return fields
    # https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=9_1
    def unifiedorder_params
      {
        body: "#{order.store.name}-商品订单支付",
        out_trade_no: payment.number,
        total_fee: (order.total * 100).to_i,
        spbill_create_ip: order&.ip_address,
        notify_url: "#{Rails.application.credentials.dig(Rails.env.to_sym, :host)}/orders/notify",
        trade_type: "JSAPI",
        openid: order.user.wechat_mp_openid
      }
    end

    def mch_account
      { appid: appid, mch_id: mch_id, key: mch_key }.freeze
    end

    def unifiedorder
      WxPay::Service.invoke_unifiedorder unifiedorder_params, mch_account.dup
    end
  end
end
