# frozen_string_literal: true

class AdminAPI::V1::VerificationCodes < AdminAPI::V1
  namespace :verification_codes, desc: "验证码接口" do
    desc "发送验证码"
    params do
      requires :target, type: String, desc: "邮箱"
      requires :event, type: String, desc: "事件类型", values: %w[sign_up reset_password]
      requires :rucaptcha, desc: "图片验证码内容"
    end
    throttle max: 10, per: 1.minute
    post do
      verify_rucaptcha!

      target = params[:target]

      check_email!(target)

      admin_user = AdminUser.find_by_email(target)

      if params[:event] == "sign_up"
        response_error("该邮箱已被注册！") if admin_user
      else
        response_error("账号不存在！") unless admin_user
      end

      vc = VerificationCode.new(target, params[:event])

      if vc.code.present? && !vc.can_send_again?
        response_error("验证码已经发送")
      else
        vc.send_code

        options = {}
        options[:verification_code] = vc.code if Rails.env.development?
        response_success("验证码已发送", options)
      end
    end
  end
end
