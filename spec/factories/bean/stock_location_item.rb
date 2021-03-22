# frozen_string_literal: true

FactoryBot.define do
  factory :stock_location_item, class: "Bean::StockLocationItem" do
    count_on_hand { 1 }
    variant
    stock_location
  end
end
