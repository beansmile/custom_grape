# frozen_string_literal: true
require "test_helper"

class ::AdminAPI::V1::MineTest < ActionDispatch::IntegrationTest
  describe "GET /admin_api/v1/mine" do
    it "succeed" do
      auth_get "/admin_api/v1/mine"

      assert_response :success
    end

    it "unauthorized" do
      get "/admin_api/v1/mine"

      assert_response :unauthorized
    end
  end

  describe "PUT /admin_api/v1/mine" do
    let(:au) { admin_users(:one) }
    it "succeed" do
      auth_put(
        "/admin_api/v1/mine",
        params: {
          phone: "13800138001",
        },
        admin_user: au
      )

      assert_response :success
      au.reload
      assert_equal "+8613800138001", au.phone
    end
  end
end
