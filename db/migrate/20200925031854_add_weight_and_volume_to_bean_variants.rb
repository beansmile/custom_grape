# frozen_string_literal: true

class AddWeightAndVolumeToBeanVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_variants, :weight, :decimal, precision: 8, scale: 2
    add_column :bean_variants, :length, :decimal, precision: 8, scale: 2
    add_column :bean_variants, :width, :decimal, precision: 8, scale: 2
    add_column :bean_variants, :depth, :decimal, precision: 8, scale: 2
  end
end
