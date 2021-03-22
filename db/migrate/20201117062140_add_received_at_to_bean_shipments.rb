class AddReceivedAtToBeanShipments < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_shipments, :received_at, :datetime
  end
end
