# frozen_string_literal: true

class ChangeAllActiveColumnToIsActive < ActiveRecord::Migration[6.0]
  def change
    rename_column :bean_merchants, :active, :is_active
    rename_column :bean_payment_methods, :active, :is_active
    rename_column :bean_stock_locations, :active, :is_active
    rename_column :bean_store_variants, :active, :is_active
    remove_column :bean_store_variants, :count_on_hand, :integer, default: 0
  end
end
