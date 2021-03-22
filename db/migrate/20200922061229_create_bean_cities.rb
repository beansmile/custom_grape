# frozen_string_literal: true

class CreateBeanCities < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_cities do |t|
      t.string :name
      t.string :code
      t.belongs_to :province, null: false, foreign_key: { to_table: "bean_provinces" }

      t.timestamps
    end
  end
end
