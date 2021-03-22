# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MagicBeanBackend
  class Application < Rails::Application
    config.paths.add "lib", eager_load: true, autoload: true
    config.paths.add "app/services", eager_load: false, autoload: true
    config.action_mailer.default_url_options = { host: Rails.application.credentials.dig(Rails.env.to_sym, :host) }
    config.action_mailer.smtp_settings = Rails.application.credentials.dig(Rails.env.to_sym, :smtp_setting)&.symbolize_keys!

    redis_config = Rails.application.credentials.dig(Rails.env.to_sym, :redis)
    redis_url = redis_config.dig(:redis_url)
    redis_namespace = "#{Rails.application.class.module_parent.name.underscore}_#{Rails.env}"
    config.cache_store = :redis_cache_store, { url: redis_url, namesapce: redis_namespace }

    config.active_record.default_timezone = :local
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    Rails.autoloaders.main.ignore(Rails.root.join("lib/generators")) unless Rails.env.development?

    config.active_job.queue_adapter = :sidekiq

    config.time_zone = "Beijing"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    # I18n library now recommends you to enforce available locales.
    config.i18n.available_locales = [:'zh-CN', :en]
    config.i18n.default_locale = :'zh-CN'
  end
end
