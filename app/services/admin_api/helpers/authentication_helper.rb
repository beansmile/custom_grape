# frozen_string_literal: true

module AdminAPI::Helpers::AuthenticationHelper
  include ::Helpers::BaseAuthHelper

  def resource_class_name
    "AdminUser"
  end

  def current_user
    current_resource
  end

  def current_role
    current_user.admin_users_roles.find_by(id: role_id_in_request) || current_user.admin_users_roles.first
  end

  def current_store
    @current_store ||= current_role.store
  end

  def current_merchant
    @current_merchant ||= current_role.merchant
  end

  def current_application
    @current_application ||= current_role.application
  end

  def current_wechat_application_client
    @current_wechat_application_client ||= current_application&.wechat_application_client
  end

  def authenticate_admin_users_role!
    return unless role_id_in_request.present?
    return if current_user.admin_users_roles.find_by(id: role_id_in_request)

    error!({ code: Helpers::ErrorCodeHelper::ADMIN_USERS_ROLE_REMOVED, detail: {}, error_message: "当前角色已被移除，系统已为你切换到另一个角色" }, 403)
  end

  def require_authentication?
    !(request.path =~ /\/(doc|swagger_doc)/)
  end
end
