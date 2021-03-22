# frozen_string_literal: true

FactoryBot.define do
  factory :shipment, class: "Bean::Shipment" do
    number { "number" }
    cost { 6 }
    order
    stock_location

    after(:build) do |object|
      object.address ||= object.order.address
    end

    factory :shipped_shipment do
      order { create(:order, :completed, shipment_state: :shipped, generate_shipment: false) }
      state { :shipped }
      shipped_at { Time.current }
    end
  end
end
