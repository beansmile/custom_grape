# frozen_string_literal: true

FactoryBot.define do
  factory :product_option_type, class: "Bean::ProductOptionType" do
    option_type
    product
  end
end
