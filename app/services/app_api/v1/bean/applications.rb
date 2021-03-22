# frozen_string_literal: true

class AppAPI::V1::Bean::Applications < API
  namespace "bean/applications" do
    route_param :appid do
      desc "获取access token", summary: "获取access token", skip_authentication: true
      get "access_token" do
        if request.headers["Api-Authorization-Token"] != Rails.application.credentials.dig(Rails.env.to_sym, Bean::Application.api_authorization_token_key)
          error!({ error_message: "401 Unauthorized" }, 401)
        end

        { access_token: Bean::Application.find_by!(appid: params[:appid]).access_token }
      end
    end
  end

  apis [] do
    desc "获取当前应用"
    get "current" do
      @resource = current_application

      authorize_and_response_resource
    end
  end
end
