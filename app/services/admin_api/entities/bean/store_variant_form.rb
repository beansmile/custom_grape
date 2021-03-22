# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class StoreVariantForm < Grape::Entity
    expose :count_on_hand
    expose :store_variant_id
    expose :store_variant, using: StoreVariant
  end
end
