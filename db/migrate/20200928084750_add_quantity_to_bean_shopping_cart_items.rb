# frozen_string_literal: true

class AddQuantityToBeanShoppingCartItems < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_shopping_cart_items, :quantity, :integer
  end
end
