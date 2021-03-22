# frozen_string_literal: true

class AppAPI::V1::Mine < Grape::API
  namespace :mine do
    helpers do
      def resource
        @resource ||= current_user
      end
    end

    desc "返回个人信息", success: ::AppAPI::Entities::Mine
    get do
      authorize_and_response_resource
    end

    desc "更新个人信息", success: ::AppAPI::Entities::Mine
    params do
      optional :avatar, type: String, desc: "用户头像"
      optional :screen_name, type: String, desc: "用户昵称"
    end
    put do
      authorize_and_update_resource
    end
  end
end
