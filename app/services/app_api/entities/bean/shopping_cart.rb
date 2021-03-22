# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleShoppingCart < ::Entities::Model
  end

  class ShoppingCart < SimpleShoppingCart
  end

  class ShoppingCartDetail < ShoppingCart
    expose :shopping_cart_items, with: ShoppingCartItem
  end
end
