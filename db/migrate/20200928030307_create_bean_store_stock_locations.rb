# frozen_string_literal: true

class CreateBeanStoreStockLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_store_stock_locations do |t|
      t.belongs_to :store, null: false, foreign_key: { to_table: "bean_stores" }
      t.belongs_to :stock_location, null: false, foreign_key: { to_table: "bean_stock_locations" }

      t.timestamps
    end
  end
end
