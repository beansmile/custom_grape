# frozen_string_literal: true

FactoryBot.define do
  factory :store_variant, class: "Bean::StoreVariant" do
    is_active { true }
    variant
    store
    cost_price { 100 }
    origin_price { 110 }
  end
end
