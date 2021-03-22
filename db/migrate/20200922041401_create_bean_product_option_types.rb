# frozen_string_literal: true

class CreateBeanProductOptionTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_product_option_types do |t|
      t.integer :position
      t.belongs_to :option_type, null: false, foreign_key: { to_table: "bean_option_types" }
      t.belongs_to :product, null: false, foreign_key: { to_table: "bean_products" }

      t.timestamps
    end
  end
end
