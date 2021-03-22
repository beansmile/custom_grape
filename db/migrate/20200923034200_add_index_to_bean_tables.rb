# frozen_string_literal: true

class AddIndexToBeanTables < ActiveRecord::Migration[6.0]
  def change
    add_index :bean_addresses, :country_code
    add_index :bean_addresses, :province_code
    add_index :bean_addresses, :city_code
    add_index :bean_addresses, :district_code

    add_index :bean_countries, :code

    add_index :bean_provinces, :code

    add_index :bean_cities, :code

    add_index :bean_districts, :code
  end
end
