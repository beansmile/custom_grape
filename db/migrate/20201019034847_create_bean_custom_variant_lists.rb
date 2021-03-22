# frozen_string_literal: true

class CreateBeanCustomVariantLists < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_custom_variant_lists do |t|
      t.references :target, polymorphic: true
      t.integer :store_variant_ids, array: true, default: []
      t.string :title
      t.string :remark

      t.timestamps null: false
    end
  end
end
