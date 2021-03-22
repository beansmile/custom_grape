# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleCity < ::Entities::Model
    expose :name
    expose :code
  end

  class City < SimpleCity
  end

  class CityDetail < City
    expose :province, with: AdminAPI::Entities::Bean::Province
  end
end
