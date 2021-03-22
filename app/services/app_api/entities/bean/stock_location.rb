# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleStockLocation < ::Entities::Model
    expose :name
  end

  class StockLocation < SimpleStockLocation
  end

  class StockLocationDetail < StockLocation
  end
end
