# frozen_string_literal: true

class AdminAPI::V1::Mine < AdminAPI::V1
  namespace :mine, desc: "当前管理员" do
    helpers do
      def resource
        current_user
      end

      def resource_class
        AdminUser
      end

      def resource_entity
        @resource_entity ||= ::AdminAPI::Entities::Mine
      end

      def permitted_params
        [:phone]
      end
    end

    desc "当前管理员" do
      success ::AdminAPI::Entities::Mine
    end
    get do
      response_resource
    end

    desc "更新当前管理员" do
      success ::AdminAPI::Entities::Mine
    end
    params do
      optional :all, using: ::AdminAPI::Entities::Mine.documentation.slice(:phone)
    end
    put do
      update_resource
    end

    desc "修改密码" do
      success ::AdminAPI::Entities::Mine
    end
    params do
      requires :current_password
      requires :password
      requires :password_confirmation
    end
    put "change_password" do
      response_error("当前密码不正确！") unless resource.authenticate(params[:current_password])
      response_error("新密码和密码确认不一致！") if params[:password] != params[:password_confirmation]

      run_member_action(:update, { password: params[:password] })
    end
  end
end
