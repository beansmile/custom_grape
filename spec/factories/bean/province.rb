# frozen_string_literal: true

FactoryBot.define do
  factory :province, class: "Bean::Province" do
    name { "name" }
    sequence(:code) { |n| n }

    country
  end
end
