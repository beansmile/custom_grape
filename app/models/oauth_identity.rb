# frozen_string_literal: true

require "open-uri"

class OauthIdentity < ApplicationRecord
  # constants
  PROVIDERS = {
    wechat_mini_program: "wechat_mini_program".freeze, # 微信小程序
    wechat_official_account: "wechat_official_account".freeze, # wechat_official_account
    wechat_mobile_app: "wechat_mobile_app".freeze, # 微信手机 app
    wechat_work_app: "wechat_work_app".freeze # 企业微信手机 app
  }

  # concerns

  # attr related macros

  # association macros
  belongs_to :user, autosave: true

  # validation macros

  # callbacks

  # other macros

  # scopes

  # class methods

  # instance methods

  # 期望的 val 结构：
  # {
  #   user_data: {
  #     openId: "oT-nj5JT7-_Nz9GkZ78QFQazJK34",
  #     nickName: "nickName",
  #     gender: 1,
  #     language: "en",
  #     city: "city",
  #     province: "province",
  #     country: "country",
  #     avatarUrl: "avatarUrl",
  #     watermark: {
  #       timestamp: 1592556153,
  #       appid: "appid"
  #     }
  #   },
  #   session_key: "session_key",
  #   params: {
  #     code: "code",
  #     encrypted_data: "encrypted_data",
  #     iv: "iv"
  #   }
  # }
  def wechat_mini_program=(val)
    copy_val = ActiveSupport::HashWithIndifferentAccess.new(val)
    user_data = copy_val[:user_data]

    self.credentials[:session_key] = val[:session_key]
    self.user_info = user_data
    self.extra[:params] = val[:params]

    file = open(user_data[:avatarUrl])

    blob = ActiveStorage::Blob.create_after_upload!(io: file, filename: SecureRandom.uuid, content_type: file.meta["content-type"])

    if persisted?
      self.user.screen_name = user_data[:nickName]
      self.user.avatar = blob.signed_id
      self.user.sns_authorized_at = Time.current
    else
      self.build_user(
        screen_name: user_data[:nickName],
        avatar: blob.signed_id,
        sns_authorized_at: Time.current,
        application: copy_val[:application]
      )
    end

    val
  end
end
