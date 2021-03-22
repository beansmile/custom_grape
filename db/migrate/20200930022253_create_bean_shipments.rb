# frozen_string_literal: true

class CreateBeanShipments < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_shipments do |t|
      t.string :number
      t.string :company
      t.decimal :cost, precision: 10, scale: 2
      t.jsonb :traces, default: {}
      t.belongs_to :order, null: false, foreign_key: { to_table: "bean_orders" }
      t.belongs_to :address, null: false, foreign_key: { to_table: "bean_addresses" }
      t.belongs_to :stock_location, null: false, foreign_key: { to_table: "bean_stock_locations" }

      t.timestamps
    end
  end
end
