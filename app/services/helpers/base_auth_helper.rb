# frozen_string_literal: true

module Helpers
  module BaseAuthHelper

    def unauthenticated!
      error! "401 Unauthorized", 401
    end

    def authenticate!
      if !payload || !JsonWebToken.valid_payload(payload.first)
        return unauthenticated!
      end
      unauthenticated! unless current_resource
      error!({ code: Helpers::ErrorCodeHelper::USER_BLOCKED_CODE, detail: {}, error_message: "账号已被冻结" }, 401) if current_resource.respond_to?(:is_blocked?) && current_resource.is_blocked?
    end

    def current_resource
      return @current_resource if @current_resource
      if payload.present? && payload[0][token_key]
        @current_resource ||= resource_class_name.constantize.find_by(
          id: payload[0][token_key]
        )
      end
    end

    def response_token(resource)
      resource.get_access_token
    end

    def check_api_authorization_token!
      unauthenticated! if request.headers["Api-Authorization-Token"] != Rails.application.credentials.dig(Rails.env.to_sym, :api_authorization_token)
    end

    def current_application
      @application ||= Bean::Application.find_by(id: current_resource&.application_id)
    end

    def current_wechat_application_client
      @current_wechat_application_client ||= current_application&.wechat_application_client
    end

    private

    def payload
      JsonWebToken.decode(token_in_request)
    rescue
      nil
    end

    def token_in_request
      @token ||= request.headers["Authorization"]
    end

    def token_key
      "#{resource_class_name.underscore}_id"
    end

    def role_id_in_request
      @role_id ||= request.headers["Current-Role-Id"].present? ? request.headers["Current-Role-Id"].to_i : nil
    end
  end
end
