# frozen_string_literal: true
module AdminAPI::Entities
  class SimpleRole < ::Entities::Model
    expose :name
    expose :store_id
    expose :kind
  end

  class Role < SimpleRole
    expose :store, using: Bean::SimpleStore
  end

  class RoleDetail < Role
    expose :custom_permissions, documentation: {
      example: [
        {
          admin_user: {
            read: true,
            create: false,
            update: false,
            destroy: false
          },
          user: {
            read: true
          },
          role: {
            read: true,
            update: true
          }
        }
      ]
    }
  end
end
