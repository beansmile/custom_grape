# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleShippingTemplate < ::Entities::Model
    expose :name
    expose :calculate_type
  end

  class ShippingTemplate < SimpleShippingTemplate
    expose :shipping_categories, using: ShippingCategory
  end

  class ShippingTemplateDetail < ShippingTemplate
  end
end
