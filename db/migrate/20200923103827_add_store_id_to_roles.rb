# frozen_string_literal: true

# frozen_string_litral: true

class AddStoreIdToRoles < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :roles, :store, foreign_key: { to_table: "bean_stores" }
    add_column :roles, :kind, :integer, default: 0
  end
end
