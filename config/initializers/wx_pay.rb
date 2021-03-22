# frozen_string_literal: true

# wechat_config = Rails.application.credentials.dig(Rails.env.to_sym, :wechat) || {}
# required
# WxPay.appid = wechat_config[:app_id]
# WxPay.key = wechat_config[:mch_key]
# WxPay.mch_id = wechat_config[:mch_id]
# WxPay.debug_mode = true # default is `true`
# WxPay.sandbox_mode = Rails.env.development?

# if WxPay.sandbox_mode
#   begin
#     result = WxPay::Service.get_sandbox_signkey
#     WxPay.key = result["sandbox_signkey"]
#   rescue RestClient::ExceptionWithResponse, OpenSSL::SSL::SSLError
#     # Do nothing because this is exception can't be handled
#   end
# end

# cert, see https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=4_3
# using PCKS12
# if Rails.env.staging? || Rails.env.production?
#   WxPay.set_apiclient_by_pkcs12(File.read(Rails.root.join("config/apiclient_cert.p12")), wechat_config[:mch_id].to_s)
# end
# if you want to use `generate_authorize_req` and `authenticate`
# WxPay.appsecret = wechat_config[:app_secrect]

# optional - configurations for RestClient timeout, etc.
# WxPay.extra_rest_client_options = { timeout: 2, open_timeout: 3 }

#  add logger to wxpay
module WxPay
  class << self
    class_attribute :logger
    self.logger = ::Logger.new(Rails.root.join("log", "wxpay.log"))
  end
end
