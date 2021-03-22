# frozen_string_literal: true

class CreateBeanStoreVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_store_variants do |t|
      t.integer :count_on_hand, default: 0
      t.integer :sales_volume, default: 0
      t.decimal :cost_price, precision: 10, scale: 2
      t.decimal :origin_price, precision: 10, scale: 2
      t.boolean :active, default: false
      t.belongs_to :variant, null: false, foreign_key: { to_table: "bean_variants" }
      t.belongs_to :store, null: false, foreign_key: { to_table: "bean_stores" }

      t.timestamps
    end
  end
end
