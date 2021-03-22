# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: "Bean::Order" do
    item_total { 100 }
    shipment_total { 6 }
    store
    address { create(:address, user: nil) }

    transient do
      generate_shipment { true }
    end

    after(:build) do |object|
      object.total ||= object.item_total + object.shipment_total
      object.user ||= create(:user, application: object.store.merchant.application)
    end

    after(:create) do |object, evaluator|
      line_item = build(:line_item, order: object)
      object.line_items << line_item

      if evaluator.generate_shipment
        shipment = create(:shipment, order: object, cost: object.shipment_total)
        create(:inventory_unit, shipment: shipment, line_item: line_item)
        create(:stock_location_item, variant: line_item.variant, stock_location: shipment.stock_location)
      end
    end

    factory :completed_order do
      state { :completed }
      shipment_state { :pending }

      after(:create) do |object|
        object.shipments.each { |shipment| shipment.update(state: "pending") }
      end

      factory :shipped_order do
        shipment_state { :shipped }

        after(:create) do |object|
          object.shipments.each { |shipment| shipment.update(state: "shipped", shipped_at: Time.current) }
        end
      end

      factory :apply_refund_order do
        state { :applied }
        shipment_state { :init }

        after(:create) do |object|
          object.shipments.each { |shipment| shipment.update(state: "init") }
        end

        factory :refunding_order do
          state { :refunding }
        end
      end
    end
  end
end
