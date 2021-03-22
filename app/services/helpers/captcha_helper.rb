# frozen_string_literal: true

module Helpers
  module CaptchaHelper
    def rucaptcha_sesion_key_key
      session_id = session.respond_to?(:id) ? session.id : session[:session_id]
      warning_when_session_invalid if session_id.blank?

      # With https://github.com/rack/rack/commit/7fecaee81f59926b6e1913511c90650e76673b38
      # to protected session_id into secret
      session_id_digest = Digest::SHA256.hexdigest(session_id.inspect)
      ["rucaptcha-session", session_id_digest].join(":")
    end

    def warning_when_session_invalid
      return unless Rails.env.development?

      Rails.logger.warn "
        WARNING! The session.id is blank, RuCaptcha can't work properly, please keep session available.
        More details about this: https://github.com/huacnlee/rucaptcha/pull/66
      "
    end

    def verify_rucaptcha?(resource = nil, opts = {})
      opts ||= {}

      store_info = RuCaptcha.cache.read(rucaptcha_sesion_key_key)
      # make sure move used key
      RuCaptcha.cache.delete(rucaptcha_sesion_key_key) unless opts[:keep_session]

      # Make sure session exist
      return false if store_info.blank?

      # Make sure not expire
      return false if (Time.now.to_i - store_info[:time]) > RuCaptcha.config.expires_in

      # Make sure parama have captcha
      captcha = (opts[:captcha] || params[:rucaptcha] || "").downcase.strip

      return false if captcha.blank?
      return false if captcha != store_info[:code]

      true
    end

    def verify_rucaptcha!
      response_error("图片验证码不正确") unless verify_rucaptcha?
    end
  end
end
