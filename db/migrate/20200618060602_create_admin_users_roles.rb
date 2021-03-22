# frozen_string_literal: true

class CreateAdminUsersRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_users_roles do |t|
      t.belongs_to :admin_user
      t.belongs_to :role

      t.timestamps
    end
  end
end
