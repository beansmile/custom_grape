# frozen_string_literal: true

class CreateBeanOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_orders do |t|
      t.string :number
      t.decimal :item_total, precision: 10, scale: 2
      t.decimal :total, precision: 10, scale: 2
      t.decimal :shipment_total, precision: 10, scale: 2
      t.decimal :promo_total, precision: 10, scale: 2
      t.decimal :adjustment_total, precision: 10, scale: 2
      t.decimal :refund_amount, precision: 10, scale: 2
      t.datetime :completed_at
      t.integer :state, default: 0
      t.integer :shipment_state, default: 0
      t.string :user_remark
      t.string :admin_user_remark
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :store, null: false, foreign_key: { to_table: "bean_stores" }
      t.belongs_to :address, null: false, foreign_key: { to_table: "bean_addresses" }

      t.timestamps
    end
  end
end
