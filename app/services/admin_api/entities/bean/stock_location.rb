# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleStockLocation < ::Entities::Model
    expose :name
  end

  class StockLocation < SimpleStockLocation
  end

  class StockLocationDetail < StockLocation
  end
end
