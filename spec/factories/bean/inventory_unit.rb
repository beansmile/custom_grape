# frozen_string_literal: true

FactoryBot.define do
  factory :inventory_unit, class: "Bean::InventoryUnit" do
    shipment
    line_item

    after(:build) do |object|
      object.store_variant ||= object.line_item.store_variant
      object.quantity ||= object.line_item.quantity
    end
  end
end
