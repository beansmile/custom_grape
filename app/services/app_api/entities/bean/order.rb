# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleOrder < ::Entities::Model
    expose :number
    expose :user_remark
    expose :adjustment_total
    expose :item_total
    expose :promo_total
    expose :refund_amount
    expose :shipment_total
    expose :total
    expose :address_id
    expose :shipment_state
    expose :state
    expose :store_id
    expose :completed_at
    expose :order_source_type
    expose :auto_close_at, documentation: { type: DateTime }
    expose :received_at
    expose :auto_receive_at, documentation: { type: DateTime }
  end

  class Order < SimpleOrder
    expose :line_items, using: LineItem
  end

  class OrderDetail < Order
    expose :address, using: Address
    expose :store, using: SimpleStore
    expose :shipments, using: Shipment
  end

  class PreviewOrder < OrderDetail
    expose :errors do |order|
      order.errors.full_messages.join("，")
    end
  end
end
