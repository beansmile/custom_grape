# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleInventoryUnit < ::Entities::Model
    expose :quantity
  end

  class InventoryUnit < SimpleInventoryUnit
    expose :store_variant, using: StoreVariant
  end

  class InventoryUnitDetail < InventoryUnit
  end
end
