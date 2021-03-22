# frozen_string_literal: true

module Helpers::VerificationCodeHelper
  MISSSING_PARAMS = "缺少参数".freeze

  def check_phone_number!(target)
    response_error(MISSSING_PARAMS) if target.blank?
    response_error("手机号码格式错误") unless Phony.plausible?("86" + target, country_number: "86")
  end

  def check_email!(target)
    response_error(MISSSING_PARAMS) if target.blank?
    response_error("邮箱格式错误") unless VerificationCode::EMAIL_PATTERN.match? target
  end

  def check_verification_code!(target, verification_code, event)
    response_error(MISSSING_PARAMS) if verification_code.blank?
    vc = VerificationCode.public_send("build_#{event}_object", target)

    unless vc.verify(verification_code)
      if vc.retry_times >= VerificationCode::RETRY_TIMES
        error!("重试次数超过#{VerificationCode::RETRY_TIMES}次，请重新发送验证码")
      else
        response_error("验证码错误，或验证码过期")
      end
    end
  end
end
