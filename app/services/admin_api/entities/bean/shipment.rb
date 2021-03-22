# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleShipment < ::Entities::Model
    expose :number
    expose :shipping_method_name
    expose :cost
    expose :traces
    expose :order_id
    expose :state
    expose :shipped_at
  end

  class Shipment < SimpleShipment
    expose :human_address
    expose :stock_location, using: SimpleStockLocation
    expose :inventory_units, using: InventoryUnit
  end

  class ShipmentDetail < Shipment
  end
end
