# frozen_string_literal: true

class CreateBeanShippingMethodCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_shipping_method_categories do |t|
      t.belongs_to :shipping_category, null: false, foreign_key: { to_table: "bean_shipping_categories" }
      t.belongs_to :shipping_method, null: false, foreign_key: { to_table: "bean_shipping_methods" }

      t.timestamps
    end
  end
end
