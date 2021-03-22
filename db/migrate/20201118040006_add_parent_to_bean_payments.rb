class AddParentToBeanPayments < ActiveRecord::Migration[6.0]
  def change
    add_reference :bean_payments, :parent, foreign_key: { to_table: "bean_payments" }
    add_column :bean_payments, :refunding_amount, :decimal, precision: 12, scale: 2, default: 0
    add_column :bean_payments, :refunded_amount, :decimal, precision: 12, scale: 2, default: 0
  end
end
