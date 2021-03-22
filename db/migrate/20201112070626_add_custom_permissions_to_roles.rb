class AddCustomPermissionsToRoles < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :custom_permissions, :jsonb, default: {}
  end
end
