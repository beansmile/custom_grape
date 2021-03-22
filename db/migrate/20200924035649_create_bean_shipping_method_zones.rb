# frozen_string_literal: true

class CreateBeanShippingMethodZones < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_shipping_method_zones do |t|
      t.belongs_to :zone, null: false, foreign_key: { to_table: "bean_zones" }
      t.belongs_to :shipping_method, null: false, foreign_key: { to_table: "bean_shipping_methods" }

      t.timestamps
    end
  end
end
