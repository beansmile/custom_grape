# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleStoreVariant < ::Entities::Model
    expose :cost_price
    expose :origin_price
    expose :sales_volume
    expose :variant_id
    expose :is_master
    expose :store_id
  end

  class StoreVariant < SimpleStoreVariant
    expose :product_id
    expose :product_name
    expose :description
    expose_attached :product_images
    expose_attached :product_detail_images
    expose :option_values, using: OptionValue
    expose :count_on_hand
    expose :product, using: SimpleProduct
  end

  class StoreVariantDetail < StoreVariant
    expose :store, using: Store
  end
end
