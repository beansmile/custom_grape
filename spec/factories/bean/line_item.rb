# frozen_string_literal: true

FactoryBot.define do
  factory :line_item, class: "Bean::LineItem" do
    quantity { 1 }
    price { 100 }
    order
    store_variant do |object|
      store = object.order.store

      product = create(:product, merchant: store.merchant)
      variant = create(:variant, product: product)
      stock_location = create(:stock_location)
      create(:store_stock_location, store: store, stock_location: stock_location)
      create(:stock_location_item, stock_location: stock_location, variant: variant, count_on_hand: 999)

      create(:store_variant, store: store, variant: variant)
    end
  end
end
