# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| n }
    kind { :custom }

    factory :store_role do
      kind { :store }
    end
  end
end
