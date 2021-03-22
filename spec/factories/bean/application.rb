# frozen_string_literal: true

FactoryBot.define do
  factory :application, class: "Bean::Application" do
    name { "name" }
    creator { create(:admin_user) }
  end
end
