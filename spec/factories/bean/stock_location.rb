# frozen_string_literal: true

FactoryBot.define do
  factory :stock_location, class: "Bean::StockLocation" do
    name { "name" }
    is_active { true }
  end
end
