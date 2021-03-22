# frozen_string_literal: true

class CreateBeanShoppingCarts < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_shopping_carts do |t|
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
