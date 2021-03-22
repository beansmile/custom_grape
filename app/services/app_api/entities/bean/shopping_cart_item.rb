# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleShoppingCartItem < ::Entities::Model
    expose :store_variant_id
    expose :quantity
  end

  class ShoppingCartItem < SimpleShoppingCartItem
    expose :store_variant_active?, as: :store_variant_active
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

  class ShoppingCartItemDetail < ShoppingCartItem
  end
end
