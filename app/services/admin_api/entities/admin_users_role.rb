# frozen_string_literal: true
module AdminAPI::Entities
  class SimpleAdminUsersRole < ::Entities::Model
    expose :role_id
    expose :admin_user_id
    expose :store_id
  end
  class AdminUsersRole < SimpleAdminUsersRole
    expose :role, using: SimpleRole
    expose :admin_user, using: SimpleAdminUser
    expose :application, using: Bean::SimpleApplication
  end

  class AdminUsersRoleDetail < AdminUsersRole
  end
end
