# frozen_string_literal: true

class AdminAPI::V1::Passwords < AdminAPI::V1
  namespace :passwords, desc: "管理员密码" do
    desc "重置密码", {
      detail: { code: 200, message: "OK" }.to_s
    }
    params do
      requires :login_name, type: String, desc: "邮箱"
      requires :verification_code, type: String, desc: "验证码"
      requires :password, type: String, desc: "密码"
    end
    put do
      response_error("您已登录！") if current_user.present?

      admin_user = AdminUser.find_by_email(params[:login_name])

      response_error("账号不存在！") unless admin_user
      response_error("密码不能为空！") if params[:password].blank?

      verification_code_event = "reset_password"

      check_verification_code!(params[:login_name], params[:verification_code], verification_code_event)

      admin_user.assign_attributes(password: params[:password])

      response_record_error(admin_user) unless admin_user.valid?

      ApplicationRecord.db_and_redis_transaction do
        admin_user.save!

        VerificationCode.new(params[:login_name], verification_code_event).clean
      end

      response_success
    end
  end
end
