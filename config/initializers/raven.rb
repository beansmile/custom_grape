# frozen_string_literal: true

Raven.configure do |config|
  config.dsn = Rails.application.credentials.dig(Rails.env.to_sym, :raven_dsn)
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = %w[production staging]
  config.async = lambda { |event|
    SentryJob.perform_later(event)
  }
end
