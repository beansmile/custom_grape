# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class BatchStoreVariantForm < Grape::Entity
    expose :product_id
    expose :store_variant_forms, using: StoreVariantForm, documentation: { is_array: true }
  end
end
