# frozen_string_literal: true

class CreateBeanAfterSales < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_after_sales do |t|
      t.string :number
      t.integer :state, default: 0
      t.datetime :agreed_at
      t.string :reason
      t.decimal :amount
      t.integer :after_sale_type
      t.string :reject_reason
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :store, null: false, foreign_key: { to_table: "bean_stores" }
      t.belongs_to :order, null: false, foreign_key: { to_table: "bean_orders" }

      t.timestamps
    end
  end
end
