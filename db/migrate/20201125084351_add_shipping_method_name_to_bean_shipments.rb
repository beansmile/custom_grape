class AddShippingMethodNameToBeanShipments < ActiveRecord::Migration[6.0]
  def change
    rename_column :bean_shipments, :company, :shipping_method_name
  end
end
