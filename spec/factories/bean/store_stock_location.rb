# frozen_string_literal: true

FactoryBot.define do
  factory :store_stock_location, class: "Bean::StoreStockLocation" do
    store
    stock_location
  end
end
