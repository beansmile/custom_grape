# frozen_string_literal: true

class AppAPI::V1::Auth < ::API
  namespace :auth, desc: "授权登录" do
    namespace :wechat_mini_program, desc: "微信小程序授权登录" do

      helpers do
        def current_application
          @current_application ||= WechatThirdPartyPlatform::Application.find_by(appid: params[:appid])&.project_application
        end
      end

      desc "小程序静默授权登录", {
        skip_authentication: true,
        detail: <<-NOTES.strip_heredoc
          获取access_token
          ```json
          {
            access_token: "eyJhbGciOiJIUzI1Ni",
            "user": {
              "id": 7,
              "created_at": "2020-05-12T07:19:49.560Z",
              "screen_name": "",
              "tracking_code": "1Ma9jgum"
            }
          }
          ```
          NOTES
      }
      params do
        requires :code, type: String, desc: "微信用户的登录凭证(code)"
        requires :appid, type: String, desc: "小程序id"
      end
      post "code_to_sessions" do
        check_application_valid!

        response = current_wechat_application_client.code_to_session(code: params[:code])
        return response_error(response["errmsg"]) if response["errmsg"]

        identity = OauthIdentity.find_or_initialize_by(
          provider: OauthIdentity::PROVIDERS[:wechat_mini_program],
          primary_uid: response["openid"]
        )
        identity.credentials[:session_key] = response["session_key"]
        identity.build_user({ application: current_application }) unless identity.user

        if identity.save
          user = identity.user
          present access_token: ::JsonWebToken.encode({ user_id: user.id })
          present :user, user, with: ::AppAPI::Entities::Mine
        else
          response_record_error identity
        end
      end

      desc "小程序 SNS 授权", {
        detail: <<-NOTES.strip_heredoc
          更新用户 SNS 授权信息
          ```json
          {
            "id": 7,
            "created_at": "2020-05-12T07:19:49.560Z",
            "screen_name": "xxx",
            "tracking_code": "1Ma9jgum"
            "sns_authorized": true,
            "avatar": {
              "url": "http://test.example.com/rails/active_storage/disk/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdDRG9JYTJWNVNTSWhkSGhvWkRka01YUTVkbUV3Y0dOMGRqZDJNbk5xWkhvMVpEazJid1k2QmtWVU9oQmthWE53YjNOcGRHbHZia2tpZDJGMGRHRmphRzFsYm5RN0lHWnBiR1Z1WVcxbFBTSXlZVGxqTkdSbU9DMW1PV013TFRReFpqUXRPVEkwWVMweFlqZGpaRFE1TkdNd1l6SWlPeUJtYVd4bGJtRnRaU285VlZSR0xUZ25KekpoT1dNMFpHWTRMV1k1WXpBdE5ERm1OQzA1TWpSaExURmlOMk5rTkRrMFl6QmpNZ1k3QmxRNkVXTnZiblJsYm5SZmRIbHdaVWtpSFdGd2NHeHBZMkYwYVc5dUwyOWpkR1YwTFhOMGNtVmhiUVk3QmxRPSIsImV4cCI6IjIwMjAtMDctMTRUMDk6MTA6MzQuMzIxWiIsInB1ciI6ImJsb2Jfa2V5In19--a1234594832e92474806729754f3b6930df8122f/2a9c4df8-f9c0-41f4-924a-1b7cd494c0c2?content_type=application%2Foctet-stream&disposition=attachment%3B+filename%3D%222a9c4df8-f9c0-41f4-924a-1b7cd494c0c2%22%3B+filename%2A%3DUTF-8%27%272a9c4df8-f9c0-41f4-924a-1b7cd494c0c2",
              "signed_id": "eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBCdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--1995fade75ae5917e3ab27378089a371e50f49b3",
              "content_type": "application/octet-stream",
              "filename": "2a9c4df8-f9c0-41f4-924a-1b7cd494c0c2"
            }
          }
          ```
          NOTES
      }
      params do
        requires :encrypted_data, type: String, desc: "完整用户信息的加密数据"
        requires :iv, type: String, desc: "加密算法的初始向量"
      end
      post "sns_authorization" do
        @current_application = current_user.application
        identity = OauthIdentity.find_by(user_id: current_user.id)
        begin
          user_data = current_wechat_application_client.decrypt!(session_key: identity["credentials"]["session_key"], encrypted_data: params[:encrypted_data], iv: params[:iv])
        rescue StandardError => err
          return response_error(err.message)
        end

        begin
          identity = OauthIdentity.find_or_initialize_by(
            provider: OauthIdentity::PROVIDERS[:wechat_mini_program],
            primary_uid: user_data["openId"]
          )

          identity.send("#{OauthIdentity::PROVIDERS[:wechat_mini_program]}=", {
            user_data: user_data,
            session_key: identity.credentials["session_key"],
            params: {
              encrypted_data: params[:encrypted_data],
              iv: params[:iv]
            },
            application: current_application
          })
        rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
          identity = OauthIdentity.find_by(primary_uid: user_data["openId"])
        end

        if identity.save
          present identity.user, with: ::AppAPI::Entities::Mine
        else
          response_record_error identity
        end
      end

      desc "小程序授权登录；通过 code 获取 access_token", {
        skip_authentication: true,
        detail: <<-NOTES.strip_heredoc
          获取access_token
          ```json
          {
            access_token: "eyJhbGciOiJIUzI1Ni",
            "user": {
              "id": 7,
              "created_at": "2020-05-12T07:19:49.560Z",
              "screen_name": "xxx",
              "tracking_code": "1Ma9jgum"
            }
          }
          ```
          NOTES
      }
      params do
        requires :code, type: String, desc: "微信用户的登录凭证(code)"
        requires :encrypted_data, type: String, desc: "完整用户信息的加密数据"
        requires :iv, type: String, desc: "加密算法的初始向量"
        requires :appid, type: String, desc: "小程序id"
      end
      post "sessions" do
        check_application_valid!

        response = current_wechat_application_client.code_to_session(code: params[:code])

        if response["session_key"]
          begin
            user_data = current_wechat_application_client.decrypt!(session_key: response["session_key"], encrypted_data: params[:encrypted_data], iv: params[:iv])
          rescue StandardError => err
            return response_error(err.message)
          end
          begin
            identity = OauthIdentity.find_or_initialize_by(
              provider: OauthIdentity::PROVIDERS[:wechat_mini_program],
              primary_uid: user_data["openId"]
            )

            identity.send("#{OauthIdentity::PROVIDERS[:wechat_mini_program]}=", {
              user_data: user_data,
              session_key: response["session_key"],
              params: {
                code: params[:code],
                encrypted_data: params[:encrypted_data],
                iv: params[:iv]
              },
              application: current_application
            })

          rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
            identity = OauthIdentity.find_by(primary_uid: user_data["openId"])
          end
          if identity.save
            user = identity.user
            present access_token: ::JsonWebToken.encode({ user_id: user.id })
            present :user, user, with: ::AppAPI::Entities::Mine
          else
            response_record_error identity
          end
        else
          response_error response["errmsg"]
        end
      end
    end
  end
end
