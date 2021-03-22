# frozen_string_literal: true

class CreateBeanCountries < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_countries do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end
