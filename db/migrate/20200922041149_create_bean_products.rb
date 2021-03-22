# frozen_string_literal: true

class CreateBeanProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_products do |t|
      t.string :name
      t.text :description
      t.datetime :available_on
      t.datetime :discontinue_on
      t.belongs_to :merchant, null: false, foreign_key: { to_table: "bean_merchants" }

      t.timestamps
    end
  end
end
