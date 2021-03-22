# frozen_string_literal: true

class CreateBeanDistricts < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_districts do |t|
      t.string :name
      t.string :code
      t.belongs_to :city, null: false, foreign_key: { to_table: "bean_cities" }

      t.timestamps
    end
  end
end
