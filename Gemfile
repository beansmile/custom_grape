# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.4"

# Autoload dotenv in Rails.
# https://github.com/bkeepers/dotenv
gem "dotenv-rails", "~> 2.7", ">= 2.7.5" # Make sure this gem is at beginning of Gemfile

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.2", ">= 6.0.2.2"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 4.1"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 4.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Object-based searching
# https://github.com/activerecord-hackery/ransack
gem "ransack", "~> 2.3", ">= 2.3.2"

# Faker is used to easily generate fake data: names, addresses, phone numbers, etc.
# https://github.com/faker-ruby/faker
gem "faker", "~> 2.13"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]

  gem "pry-byebug", "~> 3.4"
  gem "pry-rails", "~> 0.3.4"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"

  # RSpec matchers for testing ActiveJob
  # https://github.com/gocardless/rspec-activejob
  gem "rspec-activejob", "~> 0.6.1"

  # WebMock allows stubbing HTTP requests and setting expectations on HTTP requests
  # https://github.com/bblimke/webmock
  gem "webmock", "~> 3.8", ">= 3.8.3"

  # Minitest integration for Rails
  # https://github.com/blowmage/minitest-rails
  gem "minitest-rails", "~> 6.0"

  # Mocha is intended to be used in unit tests for the Mock Object or Test Stub types of Test Double, not the Fake Object or Test Spy types. Although it would be possible to extend Mocha to allow the implementation of fakes and spies, we have chosen to keep it focused on mocks and stubs.
  # https://github.com/freerange/mocha
  gem "mocha", "~> 1.11.2"

  # factory_bot is a fixtures replacement with a straightforward definition syntax
  # https://github.com/thoughtbot/factory_bot_rails
  gem "factory_bot_rails", "~> 6.1.0"

  # rspec-rails brings the RSpec testing framework to Ruby on Rails as a drop-in alternative to its default testing framework, Minitest.
  # https://github.com/rspec/rspec-rails
  gem "rspec-rails", "~> 4.0.1"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# 依赖grape提供快捷定义API的方法
# https://github.com/beansmile/custom_grape
gem "custom_grape", github: "beansmile/custom_grape", ref: "ba8e345"

# Add OAPI/swagger v2.0 compliant documentation to your grape API
# https://github.com/ruby-grape/grape-swagger
gem "grape-swagger", "~> 1.1.0"

# Swagger UI as Rails Engine for grape-swagger gem.
# https://github.com/ruby-grape/grape-swagger-rails
gem "grape-swagger-rails", "~> 0.3"

# An API focused facade that sits on top of an object model.
# https://github.com/ruby-grape/grape-entity
gem "grape-swagger-entity", "~> 0.3"

# grape log
# https://github.com/aserafin/grape_logging
gem "grape_logging", "~> 1.8.3"

# A middleware for Grape to add endpoint-specific throttling.
# https://github.com/gottfrois/grape-attack
gem "grape-attack", github: "gottfrois/grape-attack", branch: "master"

# A pure ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard.
# https://github.com/jwt/ruby-jwt
gem "jwt", "~> 2.1.0"

# https://github.com/getsentry/raven-ruby
# Raven is a Ruby client for Sentry
gem "sentry-raven", "~> 2.9.0"

# Advanced seed data handling for Rails, combining the best practices of several methods together.
# https://github.com/mbleigh/seed-fu
gem "seed-fu", "~> 2.3"

# Simple, efficient background processing for Ruby
# https://github.com/mperham/sidekiq/
gem "sidekiq", "~> 6.0"


# Enables to set jobs to be run in specified time (using CRON notation)
# https://github.com/ondrejbartas/sidekiq-cron
gem "sidekiq-cron", "~> 1.2"

# Adds a Redis::Namespace class which can be used to namespace Redis keys
# https://github.com/resque/redis-namespace
gem "redis-namespace", "~> 1.7.0"

# This is improved from rails-settings, added caching.
# https://github.com/huacnlee/rails-settings-cached
gem "rails-settings-cached", "~> 2.1.1"

# Whitelist-based Ruby HTML and CSS sanitizer.
# https://github.com/rgrove/sanitize
gem "sanitize", "~> 5.2.1"

# A Scope & Engine based, clean, powerful, customizable and sophisticated paginator for Ruby webapps
# https://github.com/kaminari/kaminari
gem "kaminari", "~> 1.2", ">= 1.2.1"

group :development do
  # Remote multi-server automation tool
  # https://github.com/capistrano/capistrano
  gem "capistrano", "~> 3.14.0", require: false
  # RVM support for Capistrano v3
  # https://github.com/capistrano/rvm
  gem "capistrano-rvm", "~> 0.1.2", require: false
  # Rails specific Capistrano tasks
  # https://github.com/capistrano/rails
  gem "capistrano-rails", "~> 1.4.0", require: false
  # Bundler support for Capistrano 3.x
  # https://github.com/capistrano/bundler
  gem "capistrano-bundler", "~> 1.6.0", require: false
  # Remote rails console for capistrano
  # https://github.com/ydkn/capistrano-rails-console
  gem "capistrano-rails-console", "~> 2.3.0", require: false
  # A collection of capistrano tasks for syncing assets and databases
  # https://github.com/sgruhier/capistrano-db-tasks
  gem "capistrano-db-tasks", "~> 0.6", require: false
  # Puma integration for Capistrano 3
  # https://github.com/seuros/capistrano-puma
  gem "capistrano3-puma", "~> 4.0.0", require: false
  # Run any rake task on a remote server using Capistrano
  # https://github.com/sheharyarn/capistrano-rake
  gem "capistrano-rake", "~> 0.2.0", require: false
  # Sidekiq integration for Capistrano
  # https://github.com/seuros/capistrano-sidekiq
  gem "capistrano-sidekiq", "= 1.0.2", require: false

  # Help to kill N+1 queries and unused eager loading
  # https://github.com/flyerhzm/bullet
  gem "bullet", "~> 6.1"
end

# run code quality and security audit report with one command
# https://github.com/rainchen/code_quality
gem "code_quality", github: "beansmile/code_quality", branch: "update-dependency", require: false, group: :development
# Code style checking for GitHub Ruby repositories
# https://github.com/beansmile/rubocop-github
gem "rubocop-github", github: "beansmile/rubocop-github", branch: "patch-1", require: false, group: :development
# A simple Wechat pay ruby gem
# https://github.com/jasl/wx_pay
gem "wx_pay", "~> 0.21.0"
# AASM - State machines for Ruby classes (plain Ruby, ActiveRecord, Mongoid)
# https://github.com/aasm/aasm
gem "aasm", "~> 5.0.8"

# The authorization Gem for Ruby on Rails.
# https://github.com/CanCanCommunity/cancancan
gem "cancancan", "~> 3.1.0"

# Complete validation of dates, times and datetimes for Rails 5.x and ActiveModel.
# https://github.com/adzap/validates_timeliness
gem "validates_timeliness", "~> 4.1.1"

# Store different kind of actions (Like, Follow, Star, Block ...) in one table via ActiveRecord Polymorphic Association.
# https://github.com/rails-engine/action-store
gem "action-store", "~> 0.4.0"

# make http request
# https://github.com/jnunemaker/httparty
gem "httparty", "~> 0.18.0"

# Simple HTTP and REST client for Ruby, inspired by microframework syntax for specifying actions.
# https://github.com/rest-client/rest-client
# 2.1.x版本调用微信接口会报Zlib::DataError: incorrect header check，降级为2.0.x版本
gem "rest-client", "~> 2.0.2"

# Create beautiful JavaScript charts with one line of Ruby
# https://github.com/ankane/chartkick
gem "chartkick", "~> 3.4.0"

# This Gem adds useful methods to your Rails app to validate, display and save phone numbers.
# https://github.com/joost/phony_rails
gem "phony_rails", "~> 0.14.13"

# Map Redis types directly to Ruby objects. Works with any class or ORM.
# https://github.com/nateware/redis-objects
gem "redis-objects", "~> 1.5"

# The default_value_for plugin allows one to define default values for ActiveRecord models in a declarative manner
# https://github.com/FooBarWidget/default_value_for
gem "default_value_for", "~> 3.3"

# FriendlyId is the "Swiss Army bulldozer" of slugging and permalink plugins for Active Record
# https://github.com/norman/friendly_id
gem "friendly_id", "~> 5.3"

# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.7"

# A Rails engine providing essential industry of Role-based access control.
# https://github.com/rails-engine/role_core
gem "role_core", "~> 0.0"

# Simple health check of Rails app for uptime monitoring with Pingdom, NewRelic, EngineYard or uptime.openacs.org etc.
# https://github.com/ianheggie/health_check
gem "health_check", "~> 3.0.0"

# This is version 3 of the aws-sdk gem
# https://github.com/aws/aws-sdk-ruby
gem "aws-sdk-s3", require: false

# Wraps the Aliyun OSS as an Active Storage service, use Aliyun official Ruby SDK for upload.
# https://github.com/huacnlee/activestorage-aliyun
gem "activestorage-aliyun", "~> 1.0.0"

# https://github.com/carrierwaveuploader/carrierwave
# This gem provides a simple and extremely flexible way to upload files from Ruby applications.
gem "carrierwave", "~> 2.0"

# Virtus allows you to define attributes on classes, modules or class instances with optional information about types, reader/writer method visibility and coercion behavior
# https://github.com/solnic/virtus
gem "virtus", "~> 1.0.5"

# xlsx spreadsheet generation
# https://github.com/caxlsx/caxlsx
gem "caxlsx", "~> 3.0.2"

# 微信小程序第三放平台
# https://github.com/beansmile/wechat_third_party_platform
gem "wechat_third_party_platform", path: "./wechat_third_party_platform"

# A tagging plugin for Rails applications that allows for custom tagging along dynamic contexts
# https://github.com/mbleigh/acts-as-taggable-on
gem "acts-as-taggable-on", "~> 6.5.0"

# This is a Captcha gem for Rails Applications which generates captcha image by C code.
# https://github.com/huacnlee/rucaptcha
gem "rucaptcha", "~> 2.5.3"

# A simple gem provides Kuaidi100 enterprise-edition APIs, includes query the express track and subscribe notification.
# https://github.com/xifengzhu/kuaidi100
gem 'kuaidi100', github: 'xifengzhu/kuaidi100', branch: 'feature/support-multi-client'
