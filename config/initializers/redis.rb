# frozen_string_literal: true

redis_url = Rails.application.credentials.dig(Rails.env.to_sym, :redis, :redis_url)
redis_namespace = "#{Rails.application.class.parent.name.underscore}_#{Rails.env}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: redis_namespace }
  config.average_scheduled_poll_interval = 2
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: redis_namespace }
end

Sidekiq.redis do |redis|
  Redis::Objects.redis = redis
  Redis.current = redis
end
