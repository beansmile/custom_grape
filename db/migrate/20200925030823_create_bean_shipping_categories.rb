# frozen_string_literal: true

class CreateBeanShippingCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_shipping_categories do |t|
      t.string :name

      t.timestamps
    end

    add_belongs_to :bean_products, :shipping_category, foreign_key: { to_table: "bean_shipping_categories" }
    add_column :bean_products, :freight_calculation_type, :integer
    add_column :bean_products, :freight_amount, :decimal, precision: 10, scale: 2
  end
end
