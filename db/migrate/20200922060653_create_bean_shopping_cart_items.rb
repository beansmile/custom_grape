# frozen_string_literal: true

class CreateBeanShoppingCartItems < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_shopping_cart_items do |t|
      t.belongs_to :store_variant, null: false, foreign_key: { to_table: "bean_store_variants" }
      t.belongs_to :shopping_cart, null: false, foreign_key: { to_table: "bean_shopping_carts" }

      t.timestamps
    end
  end
end
