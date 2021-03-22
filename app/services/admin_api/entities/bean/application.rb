# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleApplication < ::Entities::Model
    expose :appid
    expose :name
    expose :mobile
    expose :contact
    expose :company_name
    expose :expired_at
    expose_attached :logo
    expose :wechat_application_id
    expose :share_title
    expose :hotwords

    expose :hidden_filed_show, as: :secret
  end

  class Application < SimpleApplication
    expose_attached :share_image
    expose :authorize_state
    expose :wechat_application, using: ::WechatThirdPartyPlatform::GrapeAPI::Entities::Application
    expose :store_admin_users_role_id
  end

  class ApplicationDetail < Application
  end
end
