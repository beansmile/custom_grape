# frozen_string_literal: true

Rails.application.routes.draw do
  # root to: "pages#about_common_wineries"

  post "orders/refund_notify" => "orders#refund_notify"
  post "orders/notify" => "orders#notify"
  post "apps/:id/express/notify" => "kuaidi100_express#notify"

  # require "sidekiq/web"
  # Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # username == Rails.application.credentials.dig(Rails.env.to_sym, :sidekiq, :username) &&
      # password == Rails.application.credentials.dig(Rails.env.to_sym, :sidekiq, :password)
  # end unless Rails.env.development?
  # mount Sidekiq::Web => "/sidekiq"

  mount API => "/"
  unless Rails.env.production?
    mount GrapeSwaggerRails::Engine => "/:api_type/doc",
          :constraints => { api_type: /(app_api|admin_api)/ }
  end

  require "sidekiq/web"
  require "sidekiq/cron/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == Rails.application.credentials.dig(Rails.env.to_sym, :sidekiq, :username) &&
      password == Rails.application.credentials.dig(Rails.env.to_sym, :sidekiq, :password)
  end unless Rails.env.development?
  mount Sidekiq::Web => "/sidekiq"

  root to: "home#index"

  resources :pages, only: [:show]

  mount WechatThirdPartyPlatform::Engine => "/wtpp"
end
