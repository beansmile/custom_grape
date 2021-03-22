# frozen_string_literal: true

class CreateBeanAdjustments < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_adjustments do |t|
      t.string :amount, precision: 10, scale: 2
      t.string :label
      t.belongs_to :order, null: false, foreign_key: { to_table: "bean_orders" }
      t.references :adjustable, polymorphic: true, null: false
      t.references :source, polymorphic: true, null: false

      t.timestamps
    end
  end
end
