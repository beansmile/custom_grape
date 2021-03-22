# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleShippingMethod < ::Entities::Model
    expose :name
  end

  class ShippingMethod < SimpleShippingMethod
    expose :calculator, using: Calculator
  end

  class ShippingMethodDetail < ShippingMethod
  end
end
