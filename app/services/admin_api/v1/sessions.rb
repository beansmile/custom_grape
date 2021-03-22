# frozen_string_literal: true

class AdminAPI::V1::Sessions < AdminAPI::V1
  namespace :sessions, desc: "会话" do
    desc "登录", skip_authentication: true, detail: <<-DETAIL.strip_heredoc
        返回签名

        ```json
        {
          "token": "token"
        }
        ```
      DETAIL
    params do
      requires :login_name, type: String, desc: "邮箱"
      requires :password, type: String, desc: "密码"
      requires :rucaptcha, desc: "图片验证码内容"
    end
    throttle max: 10, per: 1.minute
    post do
      verify_rucaptcha!

      # login_key = params[:login_name].include?("@") ? :email : :phone
      # admin_user = AdminUser.find_by("#{login_key}": params[:login_name])
      # TODO 暂时改成只支持邮箱登录
      admin_user = AdminUser.find_by_email(params[:login_name])

      if admin_user&.authenticate(params[:password])
        @current_resource = admin_user
        present response_token(admin_user)
        present :admin_user, admin_user, with: AdminAPI::Entities::Mine
      else
        response_error("账号或密码错误。")
      end
    end
  end
end
