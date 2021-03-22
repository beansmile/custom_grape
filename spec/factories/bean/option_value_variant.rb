# frozen_string_literal: true

FactoryBot.define do
  factory :option_value_variant, class: "Bean::OptionValueVariant" do
    variant
    option_value
  end
end
