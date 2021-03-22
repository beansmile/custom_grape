# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleAddress < ::Entities::Model
    expose :detail_info
    expose :postal_code
    expose :receiver_name
    expose :tel_number
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
