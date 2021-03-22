# frozen_string_literal: true

class AdminAPI::V1::Registrations < AdminAPI::V1
  namespace :registrations do
    desc "注册"
    params do
      requires :login_name, type: String, desc: "邮箱"
      requires :verification_code, type: String, desc: "验证码"
      requires :password, type: String, desc: "密码"
    end
    throttle max: 10, per: 1.minute
    post do
      login_key = :email
      verification_code_event = "sign_up"

      admin_user = AdminUser.find_by_email(params[:login_name])

      response_error("该邮箱已被注册！") if admin_user

      check_verification_code!(params[:login_name], params[:verification_code], verification_code_event)

      admin_user = AdminUser.new(email: params[:login_name], password: params[:password])

      ApplicationRecord.db_and_redis_transaction do
        response_record_error(admin_user) unless admin_user.save

        ::Bean::Application.create!(name: "MagicBean#{Time.now.strftime("%y%m%d%H%M%S")}", creator: admin_user)

        VerificationCode.new(params[:login_name], verification_code_event).clean
      end

      response_token(admin_user)
    end
  end
end
