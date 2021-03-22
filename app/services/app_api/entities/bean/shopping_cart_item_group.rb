# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleShoppingCartItemGroup < Grape::Entity
  end

  class ShoppingCartItemGroup < SimpleShoppingCartItemGroup
    expose :store, using: Store
    expose :shopping_cart_items, using: ShoppingCartItem
  end

  class ShoppingCartItemGroupDetail < ShoppingCartItemGroup
  end
end
