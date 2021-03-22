# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_cart, class: "Bean::ShoppingCart" do
    user
  end
end
