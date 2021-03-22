class AddOrderSourceTypeToBeanOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_orders, :order_source_type, :integer
  end
end
