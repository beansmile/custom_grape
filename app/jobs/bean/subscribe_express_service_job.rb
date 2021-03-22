# frozen_string_literal: true

class Bean::SubscribeExpressServiceJob < ApplicationJob

  def perform(shipment)
    # TODO: 调用链条有点长
    express_service = shipment.order.user.application.current_express_service
    express_service.subscribe({
      number: shipment.number,
      kdbm: shipment.shipping_category&.company_code,
      mobile: shipment.order.address.tel_number
    }) if express_service
  end
end
