# frozen_string_literal: true
module AdminAPI::Entities
  class SimpleUser < ::Entities::Model
    expose :screen_name
    expose :sns_authorized
  end

  class User < SimpleUser
    expose_attached :avatar
    expose :profile_phone
    expose :profile_gender
  end

  class UserDetail < User
  end
end
