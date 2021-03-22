# frozen_string_literal: true

server "47.106.22.24", user: "deploy", roles: %w{app db web}

set :app_url, "https://hk-win-win.beansmile-dev.com/admin"
set :user, "deploy"
set :rvm_ruby_version, "2.6.4"
set :rails_env, "staging"
set :branch, "develop"
set :puma_workers, 1
