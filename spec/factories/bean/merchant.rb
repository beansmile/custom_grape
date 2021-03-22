# frozen_string_literal: true

FactoryBot.define do
  factory :merchant, class: "Bean::Merchant" do
    name { "name" }
    free_freight_amount { 5 }
    is_active { true }

    application
  end
end
