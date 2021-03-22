# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bean::Payment, type: :model do
  before do
    create(:store_role)
  end

  describe "#handle_pay_notify" do
    let(:application) { create(:application) }
    let(:merchant) { create(:merchant, application: application) }
    let(:store) { create(:store, merchant: merchant) }
    let(:result) do
      {
        "time_end" => "20141030133525"
      }
    end
    let(:payment) { create(:payment, order: order, payment_method: payment_method, payment_type: "charge") }
    let(:order) { create(:order, store: store) }
    let(:payment_method) { create(:payment_method_wechat, application: application) }

    before do
      payment.handle_pay_notify(result)
    end

    it "update payment" do
      expect(payment.completed?).to eq(true)
    end

    it "update order" do
      expect(payment.order.completed?).to eq(true)
    end
  end

  describe "refund!" do
    let(:payment) { create(:refund_payment) }
    let(:resp_data) do
      {
        "return_code" => "SUCCESS",
        "return_msg" => "OK",
        "appid" => "appid",
        "mch_id" => "mch_id",
        "nonce_str" => "yLlRUi7QGAcSfJIC",
        "sign" => "h70D3821763BF155B98B1BAA50850957D",
        "result_code" => result_code,
        "err_code_des" => "",
        "transaction_id" => "123",
        "out_trade_no" => payment.parent.number,
        "out_refund_no" => payment.number,
        "refund_id" => "456",
        "refund_channel" => "",
        "refund_fee" => 1000
      }
    end
    let("result_code") { "SUCCESS" }

    before do
      pkcs12 = double("pkcs12")
      File.stub(:read)
      OpenSSL::PKCS12.stub(:new).and_return(pkcs12)
      pkcs12.stub(:certificate)
      pkcs12.stub(:key)
      WxPay::Service.stub(:invoke_refund).and_return({ :raw => { "xml"=> resp_data } }.merge(resp_data))
    end

    it "update payment" do
      payment.refund!

      expect(payment.response).not_to eq(nil)
    end

    context "when result code is FAIL" do
      let("result_code") { "FAIL" }

      it "raise error" do
        expect { payment.refund! }.to raise_error(RuntimeError)
        expect(payment.failure?).to eq(true)
      end
    end
  end

  describe "#complete_refund" do
    let(:order) { create(:refunding_order) }
    let(:payment) { create(:refund_payment, order: order, amount: payment_amount) }
    let(:payment_amount) { order.total }

    before do
      payment.complete_refund
    end

    it "update order state" do
      expect(payment.order.cancelled?).to eq(true)
    end

    context "when only refund partial amount" do
      let(:payment_amount) { order.total - 1 }

      it "not update order state" do
        expect(payment.order.refunding?).to eq(true)
      end
    end
  end
end
