# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_cart_item, class: "Bean::ShoppingCartItem" do
    quantity { 1 }
    shopping_cart
    store_variant do |object|
      merchant = create(:merchant, application: object.shopping_cart.user.application)
      store = create(:store, merchant: merchant)
      product = create(:product, merchant: merchant)
      variant = create(:variant, product: product)
      stock_location = create(:stock_location)
      create(:store_stock_location, store: store, stock_location: stock_location)
      create(:stock_location_item, stock_location: stock_location, variant: variant, count_on_hand: 999)

      create(:store_variant, store: store, variant: variant)
    end
  end
end
