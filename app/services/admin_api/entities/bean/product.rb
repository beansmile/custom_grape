# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleProduct < ::Entities::Model
    expose :name
    expose :available_on
    expose :discontinue_on
    expose :shipping_template_id
  end

  class Product < SimpleProduct
  end

  class ProductDetail < Product
    expose :description
    expose :shipping_template, using: SimpleShippingTemplate
    expose :option_types, using: SimpleOptionType
    expose :variants, using: Variant
    expose :taxon_ids, documentation: { type: Array[Integer] }
    expose :taxons, using: SimpleTaxon
    expose_attached :images
    expose_attached :detail_images
  end
end
