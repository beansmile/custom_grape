# frozen_string_literal: true

class CreateBeanFreightTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_freight_templates do |t|
      t.string :name
      t.belongs_to :country, foreign_key: { to_table: :bean_countries }
      t.belongs_to :store, null: false, foreign_key: { to_table: "bean_stores"}

      t.timestamps
    end
  end
end
