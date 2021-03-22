# frozen_string_literal: true

FactoryBot.define do
  factory :payment_method_wechat, class: "Bean::PaymentMethod::Wechat" do
    name { "微信支付" }
    is_active { true }
    application
  end
end
