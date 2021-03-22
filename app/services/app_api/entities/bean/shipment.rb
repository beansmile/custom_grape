# frozen_string_literal: true

module AppAPI::Entities::Bean
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
    expose :inventory_units, using: InventoryUnit
    expose :shipping_rates, using: ShippingRate
    expose :stock_location, using: SimpleStockLocation
  end

  class ShipmentDetail < Shipment
  end
end
