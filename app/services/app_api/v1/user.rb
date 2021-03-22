# frozen_string_literal: true

class AppAPI::V1::User < Grape::API
  namespace :user, desc: "用户API" do
    if Rails.env.staging? || Rails.env.development?
      desc "开发环境用户快速登录 token", skip_authentication: true, detail: <<-NOTES.strip_heredoc
      ```json
      {
        "access_token": "7f42105510fe33ff62f31084461e0830"
      }
      ```
      NOTES
      params do
        requires :user_id, type: Integer, desc: "用户id"
      end
      get "user_token" do
        user = User.find params[:user_id]
        present access_token: ::JsonWebToken.encode({user_id: user.id})
      end
    end
  end
end
