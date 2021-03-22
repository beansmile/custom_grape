# frozen_string_literal: true

class AddApplicationIdToAdminUsersRoles < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :admin_users_roles, :application, foreign_key: { to_table: "bean_applications" }
    add_belongs_to :admin_users_roles, :merchant, foreign_key: { to_table: "bean_merchants" }
    add_belongs_to :admin_users_roles, :store, foreign_key: { to_table: "bean_stores" }

    remove_belongs_to :admin_users, :application, foreign_key: { to_table: "bean_applications" }
    remove_belongs_to :admin_users, :merchant, foreign_key: { to_table: "bean_merchants" }
    remove_belongs_to :admin_users, :store, foreign_key: { to_table: "bean_stores" }
  end
end
