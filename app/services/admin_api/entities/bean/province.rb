# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleProvince < ::Entities::Model
    expose :name
    expose :code
  end

  class Province < SimpleProvince
  end

  class ProvinceDetail < Province
    expose :country, with: AdminAPI::Entities::Bean::Country
  end
end
