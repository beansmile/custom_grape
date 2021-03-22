# frozen_string_literal: true

class AddMerchantIdToBeanTaxonomies < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :bean_taxonomies, :merchant, foreign_key: { to_table: :bean_merchants }
  end
end
