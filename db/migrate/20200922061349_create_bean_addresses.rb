# frozen_string_literal: true

class CreateBeanAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_addresses do |t|
      t.string :country_code, foreign_key: { to_table: :bean_countries, primary_key: :code }
      t.string :province_code, foreign_key: { to_table: :bean_provinces, primary_key: :code }
      t.string :city_code, foreign_key: { to_table: :bean_cities, primary_key: :code }
      t.string :district_code, foreign_key: { to_table: :bean_districts, primary_key: :code }
      t.string :detail_info
      t.string :postal_code
      t.string :receiver_name
      t.string :tel_number
      t.boolean :is_default, default: false
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
