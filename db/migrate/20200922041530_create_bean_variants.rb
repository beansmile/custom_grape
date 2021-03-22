# frozen_string_literal: true

class CreateBeanVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_variants do |t|
      t.string :sku
      t.integer :position
      t.datetime :available_on
      t.datetime :discontinue_on
      t.boolean :track_inventory, default: false
      t.belongs_to :product, null: false, foreign_key: { to_table: "bean_products" }

      t.timestamps
    end
  end
end
