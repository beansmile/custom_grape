# frozen_string_literal: true

class CreateBeanTaxons < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_taxons do |t|
      t.string :name
      t.belongs_to :taxonomy, null: false, foreign_key: { to_table: "bean_taxonomies" }
      t.belongs_to :parent, foreign_key: { to_table: "bean_taxons" }

      t.timestamps
    end
  end
end
