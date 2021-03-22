# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_shipping_weight, class: "Bean::Calculator::Shipping::Weight" do
    preferences do
      {
        first_weight: "1",
        first_weight_price: "6",
        continued_weight: "1",
        continued_weight_price: "0"
      }
    end
  end
end
