# frozen_string_literal: true

class CreateBeanInventoryUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_inventory_units do |t|
      t.integer :quantity
      t.belongs_to :store_variant, null: false, foreign_key: { to_table: "bean_store_variants" }
      t.belongs_to :order, null: false, foreign_key: { to_table: "bean_orders" }
      t.belongs_to :shipment, null: false, foreign_key: { to_table: "bean_shipments" }
      t.belongs_to :line_item, null: false, foreign_key: { to_table: "bean_line_items" }

      t.timestamps
    end
  end
end
