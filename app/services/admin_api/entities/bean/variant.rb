# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleVariant < ::Entities::Model
    expose :sku
    expose :weight
    expose :length
    expose :width
    expose :depth
  end

  class Variant < SimpleVariant
    expose :name
    expose :option_value_ids, documentation: { type: Array[Integer] }
    expose :option_values, using: SimpleOptionValue
  end

  class VariantDetail < Variant
  end
end
