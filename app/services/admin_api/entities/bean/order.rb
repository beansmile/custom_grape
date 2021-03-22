# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleOrder < ::Entities::Model
    expose :admin_user_remark
    expose :number
    expose :user_remark
    expose :adjustment_total
    expose :item_total
    expose :promo_total
    expose :refund_amount
    expose :shipment_total
    expose :total
    expose :shipment_state
    expose :state
    expose :completed_at
    expose :received_at
  end

  class Order < SimpleOrder
    expose :address, using: Address
    expose :line_items, using: LineItem
    expose :user, using: AdminAPI::Entities::SimpleUser
  end

  class OrderDetail < Order
    expose :store, using: SimpleStore
  end
end
