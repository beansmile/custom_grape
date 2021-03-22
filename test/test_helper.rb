# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require "webmock/minitest"
require "minitest/unit"
require "mocha/minitest"
require "active_storage/service/disk_service"

# http://docs.seattlerb.org/minitest/Minitest/Assertions.html
# https://guides.rubyonrails.org/testing.html#available-assertions

# Consider setting MT_NO_EXPECTATIONS to not add expectations to Object.
# ENV["MT_NO_EXPECTATIONS"] = true

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  before do
    signed_id = active_storage_blobs(:one).signed_id

    [Banner, User].each do |record|
      record.all.find_each do |r|
        record.attachment_reflections.keys.each do |k|
          r.send("#{k}=", signed_id)
        end
        r.save
      end
    end
  end
end

ActiveStorage::Service::DiskService.class_eval do
  def current_host
    "http://test.example.com"
  end
end

ActionDispatch::IntegrationTest.class_eval do
  def json_resp
    JSON.parse(response.body)
  end

  def initialize_application
    Bean::Application.find_or_create_by!(appid: "wx7dd9520884e4b929")
  end

  %w[get post put patch delete head].each do |method_name|
    define_method("auth_#{method_name}") do |path, **args|
      admin_user = args.delete(:admin_user) || admin_users(:one)
      admin_user.roles.each do |role|
        role.set_permissions
        role.save
      end

      args[:headers] ||= {}
      args[:headers]["Authorization"] ||= admin_user.get_access_token[:token]
      send method_name, path, args
    end

    define_method("user_#{method_name}") do |path, **args|
      user = args.delete(:user) || users(:one)

      args[:headers] ||= {}
      args[:headers]["Authorization"] ||= user.get_access_token[:token]
      send method_name, path, args
    end
  end
end
