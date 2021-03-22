# frozen_string_literal: true

class AddStoreIdToAdminUsers < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :admin_users, :store, foreign_key: { to_table: "bean_stores" }
    add_belongs_to :admin_users, :merchant, foreign_key: { to_table: "bean_merchants" }
    add_belongs_to :admin_users, :application, foreign_key: { to_table: "bean_applications" }
  end
end
