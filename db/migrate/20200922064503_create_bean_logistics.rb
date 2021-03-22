# frozen_string_literal: true

class CreateBeanLogistics < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_logistics do |t|
      t.string :number
      t.string :company
      t.jsonb :traces, default: {}
      t.string :remark
      t.belongs_to :order, null: false, foreign_key: { to_table: "bean_orders" }

      t.timestamps
    end
  end
end
