# frozen_string_literal: true

class CreateBeanTaxonomies < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_taxonomies do |t|
      t.string :name
      t.string :position
      t.integer :taxonomy_type

      t.timestamps
    end
  end
end
