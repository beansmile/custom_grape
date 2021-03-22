# frozen_string_literal: true

class CreateBeanPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_payments do |t|
      t.decimal :amount, precision: 10, scale: 2
      t.string :number
      t.integer :state, default: 0
      t.integer :payment_type
      t.jsonb :response, default: {}
      t.belongs_to :order, null: false, foreign_key: { to_table: "bean_orders" }
      t.belongs_to :payment_method, null: false, foreign_key: { to_table: "bean_payment_methods" }
      t.references :paymentable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
