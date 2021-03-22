# frozen_string_literal: true
module AdminAPI::Entities
  class SimpleAdminUser < ::Entities::Model
    expose :email
    expose :name
    expose :phone
  end

  class AdminUser < SimpleAdminUser
    expose :admin_users_roles, as: :admin_users_roles_attributes, using: AdminUsersRoleDetail
  end

  class AdminUserDetail < AdminUser
  end

  class Mine < AdminUserDetail
    expose :current_role, using: AdminUsersRole
  end
end
