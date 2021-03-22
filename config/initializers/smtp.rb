# frozen_string_literal: true

smtp_settings = Rails.application.credentials.dig(Rails.env.to_sym, :smtp) || {}

Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  address:              smtp_settings[:address],
  domain:               smtp_settings[:domain],
  port:                 smtp_settings[:port],
  user_name:            smtp_settings[:user_name],
  password:             smtp_settings[:password],
  authentication:       smtp_settings[:authentication]
}
