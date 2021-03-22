# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleLineItem < ::Entities::Model
    expose :price
    expose :quantity
    expose :store_variant_id
    expose :product_name
    expose :option_types
    expose_attached :image
  end

  class LineItem < SimpleLineItem
    expose :store_variant, using: StoreVariant
  end

  class LineItemDetail < LineItem
  end
end
