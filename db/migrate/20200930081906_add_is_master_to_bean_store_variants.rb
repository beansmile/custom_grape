# frozen_string_literal: true

class AddIsMasterToBeanStoreVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_store_variants, :is_master, :boolean, default: false
  end
end
