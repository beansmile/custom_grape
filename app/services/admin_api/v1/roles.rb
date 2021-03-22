# frozen_string_literal: true
class AdminAPI::V1::Roles < API
  include Grape::Kaminari

  apis [:index, :show, :create, :update, :destroy], { skip_authentication_apis: [] } do
    helpers do
      params :index_params do
        optional :name_cont, @api.resource_entity.documentation[:name]
      end

      params :create_params do
        requires :all, using: AdminAPI::Entities::RoleDetail.documentation.slice(:name)
        optional :custom_permissions, type: Hash, desc: "角色定义" do
          ::Role.permissions_hash.each do |key, permissions|
            optional key, type: Hash do
              permissions.each do |action, value|
                optional action, type: Grape::API::Boolean, default: value
              end
            end
          end if Role.connected? && Role.table_exists?
        end
      end

      params :update_params do
        optional :all, using: AdminAPI::Entities::RoleDetail.documentation.slice(:name)
        optional :custom_permissions, type: Hash, desc: "角色定义" do
          ::Role.permissions_hash.each do |key, permissions|
            optional key, type: Hash do
              permissions.each do |action, value|
                optional action, type: Grape::API::Boolean, default: value
              end
            end
          end if Role.connected? && Role.table_exists?
        end
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(store_id: current_store&.id))
      end
    end

    desc "权限列表"
    get "permissions_attributes" do
      present ({
        permissions_attributes: Role.permissions_hash,
        ability_i18n: Role.cached_i18n
      })
    end

    desc "当前用户可管理的所有角色"
    get "can_manage_roles" do
      # 角色类型排越前，可管理的角色越多
      sort_array = ["super", "application", "merchant", "store", "custom"]
      @ability_user = current_user.admin_users_roles.includes(:role).sort_by { |aur| sort_array.index(aur.kind) || sort_array.size }.first

      params[:page] = 0
      response_collection
    end
  end
end
