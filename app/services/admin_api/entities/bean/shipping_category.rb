# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleShippingCategory < ::Entities::Model
    expose :name
    expose :company_code
  end

  class ShippingCategory < SimpleShippingCategory
    expose :shipping_methods, using: ShippingMethod
  end

  class ShippingCategoryDetail < ShippingCategory
  end
end
