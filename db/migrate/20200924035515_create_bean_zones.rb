# frozen_string_literal: true

class CreateBeanZones < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_zones do |t|
      t.string :name
      t.string :description
      t.integer :kind

      t.timestamps
    end
  end
end
