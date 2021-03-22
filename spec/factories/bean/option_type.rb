# frozen_string_literal: true

FactoryBot.define do
  factory :option_type, class: "Bean::OptionType" do
    name { "name" }

    merchant
  end
end
