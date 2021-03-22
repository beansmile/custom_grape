class AddReceivedAtToBeanOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_orders, :received_at, :datetime
    remove_column :bean_shipments, :received_at, :datetime
  end
end
