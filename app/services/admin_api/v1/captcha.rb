# frozen_string_literal: true
class AdminAPI::V1::Captcha < API
  namespace "captcha" do
    desc "生成图片验证码"
    get do
      res = RuCaptcha.generate
      session_val = {
        code: res[0],
        time: Time.now.to_i
      }
      RuCaptcha.cache.write(rucaptcha_sesion_key_key, session_val, expires_in: RuCaptcha.config.expires_in)

      content_type "image/gif"
      env["api.format"] = :binary

      res[1]
    end
  end
end
