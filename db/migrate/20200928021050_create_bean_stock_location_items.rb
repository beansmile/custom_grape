# frozen_string_literal: true

class CreateBeanStockLocationItems < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_stock_location_items do |t|
      t.integer :count_on_hand, default: 0
      t.belongs_to :stock_location, null: false, foreign_key: { to_table: "bean_stock_locations" }
      t.belongs_to :variant, null: false, foreign_key: { to_table: "bean_variants" }

      t.timestamps
    end
  end
end
