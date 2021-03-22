# frozen_string_literal: true

class CreateBeanAfterSaleItems < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_after_sale_items do |t|
      t.integer :quantity
      t.belongs_to :after_sale, null: false, foreign_key: { to_table: "bean_after_sales" }
      t.belongs_to :line_item, null: false, foreign_key: { to_table: "bean_line_items" }

      t.timestamps
    end
  end
end
