# frozen_string_literal: true

class CreateBeanMerchants < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_merchants do |t|
      t.string :name
      t.boolean :active, default: false
      t.belongs_to :application, null: false, foreign_key: { to_table: "bean_applications" }

      t.timestamps
    end
  end
end
