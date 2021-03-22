# frozen_string_literal: true

class ChangeStoreActiveToDiscontinueOn < ActiveRecord::Migration[6.0]
  def change
    remove_column :bean_stores, :active, :boolean, default: false
    add_column :bean_stores, :discontinue_on, :datetime
  end
end
