# frozen_string_literal: true

FactoryBot.define do
  factory :option_value, class: "Bean::OptionValue" do
    name { "name" }

    option_type
  end
end
