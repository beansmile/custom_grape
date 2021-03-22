# frozen_string_literal: true

class CreateBeanShippingTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_shipping_templates do |t|
      t.string :name
      t.integer :calculate_type
      t.belongs_to :merchant, null: false, foreign_key: { to_table: "bean_merchants" }

      t.timestamps
    end
  end
end
