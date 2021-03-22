# frozen_string_literal: true

class ChangeBeanVariantsAvailableOnAndDiscontinueOnToIsActive < ActiveRecord::Migration[6.0]
  def change
    remove_column :bean_variants, :available_on, :datetime
    remove_column :bean_variants, :discontinue_on, :datetime
    add_column :bean_variants, :is_active, :boolean, default: false
  end
end
