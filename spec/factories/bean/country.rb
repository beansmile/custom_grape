# frozen_string_literal: true

FactoryBot.define do
  factory :country, class: "Bean::Country" do
    name { "name" }
    sequence(:code) { |n| n }
  end
end
