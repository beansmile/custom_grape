# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleShippingRate < ::Entities::Model
    expose :selected
    expose :cost
    expose :shipping_method_id
  end

  class ShippingRate < SimpleShippingRate
  end

  class ShippingRateDetail < ShippingRate
  end
end
