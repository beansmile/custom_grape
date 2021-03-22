# frozen_string_literal: true

module Bean
  class ShoppingCart < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :user

    has_many :shopping_cart_items, class_name: "Bean::ShoppingCartItem", dependent: :destroy

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
