class AddStateToBeanShipments < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_shipments, :state, :integer, default: 0
    add_column :bean_shipments, :shipped_at, :datetime
  end
end
