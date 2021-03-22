# frozen_string_literal: true

class AddCountryIdToBeanAddresses < ActiveRecord::Migration[6.0]
  def change
    remove_index :bean_addresses, :country_code
    remove_column :bean_addresses, :country_code, :string
    remove_index :bean_addresses, :province_code
    remove_column :bean_addresses, :province_code, :string
    remove_index :bean_addresses, :city_code
    remove_column :bean_addresses, :city_code, :string
    remove_index :bean_addresses, :district_code
    remove_column :bean_addresses, :district_code, :string

    add_belongs_to :bean_addresses, :country, foreign_key: { to_table: :bean_countries }
    add_belongs_to :bean_addresses, :province, foreign_key: { to_table: :bean_provinces }
    add_belongs_to :bean_addresses, :city, foreign_key: { to_table: :bean_cities }
    add_belongs_to :bean_addresses, :district, foreign_key: { to_table: :bean_districts }
  end
end
