# frozen_string_literal: true

class CreateBeanShippingRates < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_shipping_rates do |t|
      t.boolean :selected, default: false
      t.decimal :cost, precision: 10, scale: 2
      t.belongs_to :shipment, null: false, foreign_key: { to_table: "bean_shipments" }
      t.belongs_to :shipping_method, null: false, foreign_key: { to_table: "bean_shipping_methods" }

      t.timestamps
    end
  end
end
