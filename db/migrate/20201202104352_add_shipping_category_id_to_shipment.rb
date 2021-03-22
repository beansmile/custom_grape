class AddShippingCategoryIdToShipment < ActiveRecord::Migration[6.0]
  def change
     add_belongs_to :bean_shipments, :shipping_category, foreign_key: { to_table: :bean_shipments }
  end
end
