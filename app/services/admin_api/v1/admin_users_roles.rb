# frozen_string_literal: true

class AdminAPI::V1::AdminUsersRoles < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy, {
    # resource_class: AdminUsersRole,
    # collection_entity: AdminAPI::Entities::AdminUsersRole,
    # resource_entity: AdminAPI::Entities::AdminUsersRoleDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :index_params do
        optional :admin_user_email_cont
        optional :admin_user_phone_cont
        optional :role_kind_eq
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :role_id
        )
        requires :admin_user, type: JSON do
          requires :email
        end
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :role_id
        )
      end

      def build_resource
        @resource = end_of_association_chain.new(role_id: params[:role_id], store: current_store)
      end

      def create_api
        authorize! :create, build_resource

        run_member_action(:invite, {}, { email: params[:admin_user][:email] })
      end
    end # helpers
  end # apis

  namespace :mine do
    desc "当前管理员角色" do
      success ::AdminAPI::Entities::AdminUsersRole
    end
    get "roles" do
      @resource_class = AdminUsersRole

      present current_user.admin_users_roles.includes(includes), with: collection_entity
    end
  end
end
