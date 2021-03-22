# frozen_string_literal: true

class AddPositionToBeanTaxons < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_taxons, :position, :integer, default: 0

    remove_column :bean_taxonomies, :position, :string
    add_column :bean_taxonomies, :position, :integer, default: 0
  end
end
