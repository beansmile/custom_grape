# frozen_string_literal: true

FactoryBot.define do
  factory :city, class: "Bean::City" do
    name { "name" }
    sequence(:code) { |n| n }

    province
  end
end
