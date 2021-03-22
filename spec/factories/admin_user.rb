# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "#{n}@example.com" }
    password { "password" }
  end
end
