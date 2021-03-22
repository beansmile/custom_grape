# frozen_string_literal: true

class AddMerchantToShippingCategories < ActiveRecord::Migration[6.0]
  def change
    add_reference :bean_shipping_categories, :merchant, foreign_key: { to_table: "bean_merchants" }
    add_reference :bean_shipping_methods, :merchant, foreign_key: { to_table: "bean_merchants" }
    remove_column :bean_shipping_methods, :store_id, :integer
  end
end
