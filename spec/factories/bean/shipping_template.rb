# frozen_string_literal: true

FactoryBot.define do
  factory :shipping_template, class: "Bean::ShippingTemplate" do
    name { "name" }

    merchant
  end
end
