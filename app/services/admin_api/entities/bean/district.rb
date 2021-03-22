# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleDistrict < ::Entities::Model
    expose :name
    expose :code
  end

  class District < SimpleDistrict
  end

  class DistrictDetail < District
    expose :city, with: AdminAPI::Entities::Bean::City
  end
end
