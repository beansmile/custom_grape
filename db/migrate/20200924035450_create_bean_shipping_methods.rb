# frozen_string_literal: true

class CreateBeanShippingMethods < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_shipping_methods do |t|
      t.string :name
      t.belongs_to :store, null: false, foreign_key: { to_table: "bean_stores" }

      t.timestamps
    end
  end
end
