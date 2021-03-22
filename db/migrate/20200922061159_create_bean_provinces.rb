# frozen_string_literal: true

class CreateBeanProvinces < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_provinces do |t|
      t.string :name
      t.string :code
      t.belongs_to :country, null: false, foreign_key: { to_table: "bean_countries" }

      t.timestamps
    end
  end
end
