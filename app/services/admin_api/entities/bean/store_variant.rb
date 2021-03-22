# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleStoreVariant < ::Entities::Model
    expose :cost_price
    expose :origin_price
    expose :sales_volume
    expose :store_id
    expose :variant_id
    expose :is_active
    expose :is_master
  end

  class StoreVariant < SimpleStoreVariant
    expose :product_id
    expose :product_name
    expose :variant, using: Variant
    expose :variant_name
  end

  class StoreVariantDetail < StoreVariant
  end
end
