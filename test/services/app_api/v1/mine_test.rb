# frozen_string_literal: true
require "test_helper"

class ::AppAPI::V1::MineTest < ActionDispatch::IntegrationTest

  setup :initialize_application

  describe "GET /app_api/v1/mine" do
    it "succeed" do
      user_get "/app_api/v1/mine"

      assert_response :success
    end

    it "unauthorized" do
      get "/app_api/v1/mine"

      assert_response 401
    end
  end
end
