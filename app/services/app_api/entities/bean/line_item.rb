# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleLineItem < ::Entities::Model
    expose :price
    expose :quantity
    expose :store_variant_id
    expose :product_name
    expose :option_types, documentation: { type: Array[JSON] }
  end

  class LineItem < SimpleLineItem
    expose_attached :image
    expose :store_variant, using: StoreVariant
    expose :redirect_to_store_variant_id do |resource|
      if resource.store_variant_active?
        resource.store_variant_id
        # 如果store_variant已失效，但product仍然有效，则找出is_master为true的store_variant作为跳转id
      elsif resource.store_variant.product.active?
        resource.store_variant.other_store_variants.find_by(is_master: true)&.id
      end
    end
  end

  class LineItemDetail < LineItem
  end
end
