# frozen_string_literal: true

class CreateBeanStores < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_stores do |t|
      t.string :name
      t.boolean :active, default: false
      t.belongs_to :merchant, null: false, foreign_key: { to_table: "bean_merchants" }

      t.timestamps
    end
  end
end
