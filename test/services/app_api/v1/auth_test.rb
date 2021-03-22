# frozen_string_literal: true
require "test_helper"

class ::AppAPI::V1::AuthTest < ActionDispatch::IntegrationTest
  describe "POST /app_api/v1/auth/wechat_mini_program/code_to_sessions" do
    before do
      WechatThirdPartyPlatform.stubs(:get_component_access_token).returns("component_access_token_test")
    end

    it "succeeds login with valid code" do
      assert_equal User.all.size, 2

      # MC's user info
      code_to_session_response = {
        "session_key" => "65fS7pB/IxDMwECw3FRITg==",
        "openid" => "oaGM546e7TwF7ydIWMGoIpQqbkB8"
      }
      stub_request(:get, /api.weixin.qq.com\/sns\/component\/jscode2session/)
      .to_return(body: code_to_session_response.to_json)

      post "/app_api/v1/auth/wechat_mini_program/code_to_sessions", params: { code: "011JyI8x09YBcd1dE0bx0mrK8x0JyI8F", appid: "wx7dd9520884e4b929" }, as: :json

      assert_response :success
      assert json_resp.dig("access_token")
      returned_user = json_resp.dig("user")
      assert_empty returned_user["screen_name"]
      assert_nil returned_user["avatar"]
      assert_not returned_user["sns_authorized"]
      refute_empty returned_user["tracking_code"]
      assert_equal User.all.size, 3
    end

    it "failed to login with invalid code" do
      assert_equal User.all.size, 2

      code_to_session_response = {"errcode"=>40029, "errmsg"=>"invalid code, hints: [ req_id: EFGdO6yFe-0aV ]"}
      stub_request(:get, /api.weixin.qq.com\/sns\/component\/jscode2session/)
      .to_return(body: code_to_session_response.to_json)

      post "/app_api/v1/auth/wechat_mini_program/code_to_sessions", params: { code: "invalid-code", appid: "wx7dd9520884e4b929" }, as: :json

      assert_response :bad_request
      assert_equal 40000, json_resp.dig("code")
      refute_empty json_resp.dig("error_message")
      assert_equal User.all.size, 2
    end
  end

  describe "POST /app_api/v1/auth/wechat_mini_program/sns_authorization" do
    let(:basic_authorization) { oauth_identities(:basic_authorization) }

    before do
      # avoid error: 微信解析数据错误
      WechatThirdPartyPlatform.stubs(:get_component_access_token).returns("component_access_token_test")
    end

    it "succeeds updating user's sns info" do
      stub_request(:get, "https://wx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLUlqnydeWBq21Jc27xLKLl3zMAll2wK7EXUqDGRVhiaibQPsEn9fbtvgFdtXpMVIlHuia8pJ2nreYWg/132")
      assert_equal User.all.size, 2

      identity = OauthIdentity.find_by(primary_uid: basic_authorization.primary_uid)
      user = identity.user
      assert_empty user.screen_name
      assert_not user.sns_authorized

      # Charlie's user info
      params = {
        iv: "gWYx6vYH5fnwQ+ih5zqwxw==",
        encrypted_data: "gEJTIsqrVP95xmljrE0UXwG2Few0JKRjHIxJFurmsRf8gLzcGTaamSM/GKnv2UMwOrAy9djAb1o7JVBQfZGaUDuohEh5H6GKCE4hCC68FeJ8fEz1GMv9WRBHImSrIhOhfVlO0p8tj4mcvmb2m9OqNwomgsPnMA09hPgBAoHCTlVLYivsgpBRn7n9++OtZKXJ+w/+r9lQcfwAGaXN1eJIft4mxGt1v2OUVz2yyF+2QWEiiZxKcPGZmnJQlDXCLkStGUiRyLvprQwi48ndoGP2Hbtro7IK7pDVb6CqeGtrTTBTVP1xywpZRlpEne9JJtEkt4nyIleiP35UEs9Zi9b8NrKHe5dyPjKGscSmMFcf+l6fgA5mvq3FKwW1aADy9V5vRu3jmPGixchpJDSUPWS99eh2x8otOYmrWeWCmNba0ElMbYH2dg+NmYcL0tOk2b9ktPUGxdhfkKb5zzRLDBe9iUZBDnr8eTXTQzTzx6+Ijbc=",
        appid: "wx7dd9520884e4b929"
      }

      user_post "/app_api/v1/auth/wechat_mini_program/sns_authorization", params: params, user: user, as: :json

      assert_response :success

      returned_user = json_resp
      user.reload

      assert_equal returned_user["screen_name"], user.screen_name
      assert_equal returned_user["sns_authorized"], user.sns_authorized
      refute_empty returned_user["avatar"]
      assert_equal User.all.size, 2
    end
  end

  describe "POST /app_api/v1/auth/wechat_mini_program/sessions" do
    before do
      ActiveStorage::Attachment.any_instance.stubs(:service_url)
      WechatThirdPartyPlatform.stubs(:get_component_access_token).returns("component_access_token_test")
    end

    let(:wechat_mp_auth) { oauth_identities(:wechat_mini_program) }

    it "succeeds with existing user" do
      stub_request(:get, /api.weixin.qq.com\/sns\/component\/jscode2session/)
      .to_return(
        body: {
          session_key: wechat_mp_auth.credentials["session_key"],
          openid: wechat_mp_auth.primary_uid
        }.to_json
      )

      stub_request(:get, "https://wx.qlogo.cn/mmopen/vi_32/UVbCsPicXcXnDwOQmAlyeibzK1hAsib5mWaoodlGIiaGcRcdjEeapxIvwJ1ncWwYDicHhkJTxnUuTBzTJu9svjSouEg/132")

      params = wechat_mp_auth.extra["params"]
      post "/app_api/v1/auth/wechat_mini_program/sessions", params: params.merge!({ appid: "wx7dd9520884e4b929" }), as: :json

      assert_response :success
      assert json_resp.dig("access_token")
      returned_user = json_resp.dig("user")
      assert_equal returned_user["screen_name"], wechat_mp_auth["user_info"]["nickName"]
    end

    it "succeeds creating new oatuh and user" do
      # MC's user info
      code_to_session_response = {
        "session_key" => "65fS7pB/IxDMwECw3FRITg==",
        "openid" => "oaGM546e7TwF7ydIWMGoIpQqbkB8"
      }
      stub_request(:get, /api.weixin.qq.com\/sns\/component\/jscode2session/)
      .to_return(body: code_to_session_response.to_json)

      stub_request(:get, "https://wx.qlogo.cn/mmopen/vi_32/PiajxSqBRaELTibPhcqaJdNJNmjQcGw0wiaNegnlB7Xo4LHpnroiazbFN36H1An0mMhe3aDKxibpPNhT7Z76CiasOhSg/132")

      assert_equal User.all.size, 2

      params = {
        code: "011JyI8x09YBcd1dE0bx0mrK8x0JyI8F",
        iv: "C8SyQI+FAgLywxNayzpckg==",
        encrypted_data: "7/5nucb+0QchzUeUGzAf+tQP35ozVPclnOGRCRka/rFnlGLKyhes1LUxTIkn6Ko0U3E854rDruIXcGy3TGz0qKbtHiS0E5SFqLtk3V6LQM03Z+pUpgmqUB8HQT/qSZym7Fg+A+F1fr8xEPSV8rlG1qh0uO/ijCymgisl/E/4DxKlvLiJemK4AtMMbMn4KpUse+9tOizysFk5Zq3B0XF+cf4DX9/6a/kGLK7aMpnvQBg/FvAW71cz+lfZrvOPL8eFl/D4W2S7bdlvxepKszAXphf3KTdLY5hZPngG9wvzJ4Qbx7+oOm2xgEw7jlk3Vh/8T7B+oc/iSEoKjQRPtBlGZMQHpqIBYK8PdC83Z+SUZ0hE1u2AFetnvjyY91Jn1qg8lUNZLCcjGYW6NmqoQO4LLdl/QbLXumdBTc4EotuzDEqxuWUTrHpjt+2pptfNECmj+8OborOzWDdIUYpswBbykG0HBI25a5piW20yz7kiSRY=",
        appid: "wx7dd9520884e4b929"
      }
      post "/app_api/v1/auth/wechat_mini_program/sessions", params: params, as: :json

      assert_response :success
      returned_user = json_resp.dig("user")
      refute_empty returned_user["screen_name"]
      refute_empty returned_user["avatar"]
      refute_empty returned_user["tracking_code"]
      assert returned_user["sns_authorized"]
      assert_equal User.all.size, 3
      assert_not_equal User.first.screen_name, User.last.screen_name
    end

    it "return error when providing invalid data" do
      stub_request(:get, /api.weixin.qq.com\/sns\/component\/jscode2session/)
      .to_return(
          body: {
            session_key: wechat_mp_auth.credentials["session_key"],
            openid: wechat_mp_auth.primary_uid
          }.to_json
        )

        params = {
          code: "invalid code",
          iv: "invalid iv",
          encrypted_data: "invalid encrypted data",
          appid: "wx7dd9520884e4b929"
        }
        post "/app_api/v1/auth/wechat_mini_program/sessions", params: params, as: :json

        assert_response :bad_request
        assert_equal 40000, json_resp.dig("code")
        refute_empty json_resp.dig("error_message")
    end
  end
end
