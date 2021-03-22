# frozen_string_literal: true

FactoryBot.define do
  factory :district, class: "Bean::District" do
    name { "name" }
    sequence(:code) { |n| n }

    city
  end
end
