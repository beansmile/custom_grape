# frozen_string_literal: true

class UpdateShippingRelateTables < ActiveRecord::Migration[6.0]
  def change
    remove_belongs_to :bean_products, :shipping_category, foreign_key: { to_table: "bean_shipping_categories" }
    add_belongs_to :bean_products, :shipping_template, foreign_key: { to_table: "bean_shipping_templates" }
    add_belongs_to :bean_shipping_categories, :shipping_template, foreign_key: { to_table: "bean_shipping_templates" }
    remove_belongs_to :bean_shipping_categories, :merchant, foreign_key: { to_table: "bean_merchants" }
    add_belongs_to :bean_shipping_methods, :shipping_category, foreign_key: { to_table: "bean_shipping_categories" }
    remove_belongs_to :bean_shipping_methods, :merchant, foreign_key: { to_table: "bean_merchants" }
    add_column :bean_shipping_methods, :is_default, :boolean, default: false
    remove_column :bean_merchants, :freight_amount, :decimal, precision: 10, scale: 2

    drop_table :bean_shipping_method_categories do |t|
      t.belongs_to :shipping_category, null: false, foreign_key: { to_table: "bean_shipping_categories" }
      t.belongs_to :shipping_method, null: false, foreign_key: { to_table: "bean_shipping_methods" }

      t.timestamps
    end
  end
end
