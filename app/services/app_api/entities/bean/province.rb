# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleProvince < ::Entities::Model
    expose :name
    expose :code
  end

  class Province < SimpleProvince
  end

  class ProvinceDetail < Province
    expose :country, with: AppAPI::Entities::Bean::Country
  end
end
