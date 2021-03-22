# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleInventoryUnit < ::Entities::Model
    expose :quantity
  end

  class InventoryUnit < SimpleInventoryUnit
    expose :line_item, using: SimpleLineItem
    expose :store_variant, using: StoreVariant
  end

  class InventoryUnitDetail < InventoryUnit
  end
end
