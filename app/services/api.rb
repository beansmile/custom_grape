# frozen_string_literal: true

require "wechat_third_party_platform/grape_api"

class API < Grape::API
  use GrapeLogging::Middleware::RequestLogger, logger: ::Logger.new("./log/api.log"), include: [
    GrapeLogging::Loggers::Response.new,
    GrapeLogging::Loggers::ClientEnv.new,
    GrapeLogging::Loggers::FilterParameters.new,
    GrapeLogging::Loggers::UserInfo.new
  ]
  use Grape::Attack::Throttle

  default_format :json
  format :json

  helpers ::Helpers::BaseHelper
  helpers ::Helpers::ErrorCodeHelper
  helpers ::Helpers::VerificationCodeHelper
  helpers ::Helpers::CaptchaHelper

  before do
    locale = request.headers["Locale"]&.to_sym
    if locale && I18n.available_locales.include?(locale)
      I18n.locale = locale
    else
      I18n.locale = I18n.default_locale
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |_|
    rack_response('{"error": "资源不存在！"}', 404)
  end

  rescue_from CanCan::AccessDenied do |_|
    rack_response('{"error": "没有权限进行此操作！"}', 403)
  end

  rescue_from Grape::Attack::RateLimitExceededError do |e|
    rack_response('{"error": "操作太频繁，请稍后再试！"}', 429)
  end

  mount AppAPI::V1
  mount AdminAPI::V1
end
