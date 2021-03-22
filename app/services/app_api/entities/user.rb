# frozen_string_literal: true

module AppAPI::Entities
  class SimpleUser < ::Entities::Model
    expose :screen_name
    expose :sns_authorized
    expose_attached :avatar
  end

  class User < SimpleUser
  end

  class UserDetail < User
  end

  class Mine < SimpleUser
    expose :tracking_code
    expose :init_orders_count, documentation: { desc: "待支付订单数" }
    expose :shipment_state_pending_orders_count, documentation: { desc: "待发货订单数" }
    expose :shipped_orders_count, documentation: { desc: "已发货订单数" }
  end
end
