# frozen_string_literal: true

FactoryBot.define do
  factory :store, class: "Bean::Store" do
    name { "name" }
    merchant
  end
end
