class AddKindToBeanCustomVariantLists < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_custom_variant_lists, :kind, :integer, default: 0
  end
end
