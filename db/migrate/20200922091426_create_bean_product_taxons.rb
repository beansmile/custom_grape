# frozen_string_literal: true

class CreateBeanProductTaxons < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_product_taxons do |t|
      t.belongs_to :product, null: false, foreign_key: { to_table: "bean_products" }
      t.belongs_to :taxon, null: false, foreign_key: { to_table: "bean_taxons" }

      t.timestamps
    end
  end
end
