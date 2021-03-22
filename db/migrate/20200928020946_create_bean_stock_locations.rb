# frozen_string_literal: true

class CreateBeanStockLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_stock_locations do |t|
      t.string :name
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
