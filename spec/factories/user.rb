# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    screen_name { "name" }
    application
    sns_authorized_at { Time.current }
  end
end
