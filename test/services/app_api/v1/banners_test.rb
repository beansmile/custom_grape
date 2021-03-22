# frozen_string_literal: true
require "test_helper"

class ::AppAPI::V1::BannersTest < ActionDispatch::IntegrationTest

  setup :initialize_application

  describe "GET /app_api/v1/banners" do
    it "succeed" do
      get "/app_api/v1/banners"

      assert_response :success
      assert_not_empty json_resp
    end
  end
end
