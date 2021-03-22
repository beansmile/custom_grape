# frozen_string_literal: true

FactoryBot.define do
  factory :variant, class: "Bean::Variant" do
    sequence(:sku) { |n| n }
    product
    weight { 1 }
  end
end
