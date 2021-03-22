# frozen_string_literal: true

FactoryBot.define do
  factory :shipping_category, class: "Bean::ShippingCategory" do
    name { "name" }
    company_code { "shunfeng" }

    shipping_template
  end
end
