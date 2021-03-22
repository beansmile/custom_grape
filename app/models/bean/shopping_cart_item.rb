# frozen_string_literal: true

module Bean
  class ShoppingCartItem < ApplicationRecord
    # constants

    # concerns
    include StoreVariantItemConcern

    # attr related macros
    delegate :active?, to: :store_variant, prefix: true

    # association macros
    belongs_to :shopping_cart, class_name: "Bean::ShoppingCart"
    belongs_to :store_variant, class_name: "Bean::StoreVariant"

    # validation macros
    validates :quantity, numericality: { greater_than: 0 }

    # callbacks

    # other macros

    # scopes

    # class methods
    def self.add_to_cart(shopping_cart:, store_variant_id:, quantity: 1)
      quantity ||= 1

      cart_item = shopping_cart.shopping_cart_items.find_or_initialize_by(store_variant_id: store_variant_id)

      if cart_item.new_record?
        cart_item.update(quantity: quantity)
      else
        cart_item.update_item(quantity: quantity + cart_item.quantity)
      end

      cart_item
    end

    # instance methods
    def update_item(quantity:)
      update(quantity: quantity)
    end
  end
end
