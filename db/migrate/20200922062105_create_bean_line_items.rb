# frozen_string_literal: true

class CreateBeanLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_line_items do |t|
      t.integer :quantity
      t.decimal :price, precision: 10, scale: 2
      t.decimal :adjustment_total, precision: 10, scale: 2
      t.belongs_to :order, null: false, foreign_key: { to_table: "bean_orders" }
      t.belongs_to :store_variant, null: false, foreign_key: { to_table: "bean_store_variants" }

      t.timestamps
    end
  end
end
