# frozen_string_literal: true

module AppAPI::Helpers::AuthenticationHelper
  include ::Helpers::BaseAuthHelper

  def resource_class_name
    "User"
  end

  def current_user
    current_resource
  end

  def check_application!
    check_application_valid!

    if current_application.expired?
      error!({
        code: Helpers::ErrorCodeHelper::APPLICATION_EXPIRED,
        detail: {},
        error_message: "平台服务已经过期"
      }, 403)
    end
  end

  def check_application_valid!
    return true if current_application

    error!({
      code: Helpers::ErrorCodeHelper::APPLICATION_INVALID,
      detail: {},
      error_message: "小程序没在平台授权"
    }, 400)
  end

  def require_authentication?
    return false if options.dig(:route_options, :skip_authentication)

    !(request.path =~ /\/(doc|swagger_doc)/)
  end
end
