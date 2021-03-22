# frozen_string_literal: true

FactoryBot.define do
  factory :address, class: "Bean::Address" do
    country
    province
    city
    district
    postal_code { "528400" }
    tel_number { "13800138000" }
    receiver_name { "name" }
    detail_info { "detail info" }
    user
  end
end
