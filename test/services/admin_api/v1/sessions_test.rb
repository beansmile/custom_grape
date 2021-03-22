# frozen_string_literal: true
require "test_helper"

class ::AdminAPI::V1::SessionsTest < ActionDispatch::IntegrationTest
  describe "POST /admin_api/v1/sessions" do
    let(:au) { admin_users(:one) }

    it "succeed with email login" do
      RuCaptcha.cache.stubs(:read).returns({ code: "any", time: Time.now.to_i })

      post "/admin_api/v1/sessions", params: { login_name: au.email, password: "password", rucaptcha: "any" }

      assert_response :success
      assert json_resp.dig("token")
    end

    # it "succeed with phone login" do
      # post "/admin_api/v1/sessions", params: { login_name: au.phone, password: "password" }, as: :json

      # assert_response :success
      # assert json_resp.dig("token")
    # end

    it "fail without login_name" do
      post "/admin_api/v1/sessions", params: { password: "password" }

      assert_response :bad_request
    end

    it "fail without password" do
      post "/admin_api/v1/sessions", params: { login_name: au.email }

      assert_response :bad_request
    end

    it "fail without params" do
      post "/admin_api/v1/sessions"

      assert_response :bad_request
    end
  end
end
