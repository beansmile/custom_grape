# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleAddress < ::Entities::Model
    expose :detail_info
    expose :postal_code
    expose :receiver_name
    expose :tel_number
    expose :user_id
    expose :is_default
    expose :country_id
    expose :province_id
    expose :city_id
    expose :district_id
  end

  class Address < SimpleAddress
    expose :city, using: SimpleCity
    expose :country, using: SimpleCountry
    expose :district, using: SimpleDistrict
    expose :province, using: SimpleProvince
  end

  class AddressDetail < Address
  end
end
