# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: "Bean::Payment" do
    order
    payment_type { :charge }
    payment_method { create(:payment_method_wechat) }

    after(:build) do |object|
      object.paymentable ||= object.order
      object.amount ||= object.order.total
    end

    factory :refund_payment do
      payment_type { :refund }

      after(:build) do |object|
        object.parent ||= create(:payment, state: :completed, order: object.order, paymentable: object.order)
        object.amount ||= object.parent.amount
        object.paymentable ||= object.parent.paymentable
        object.payment_method ||= object.parent.payment_method
      end
    end
  end
end
