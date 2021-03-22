# frozen_string_literal: true

module AdminAPI::Entities::Bean::SingleStore
  class SimpleVariant < Grape::Entity
    expose :id, documentation: { type: Integer }
    expose :sku, documentation: { desc: Bean::Variant.human_attribute_name(:sku) }
    expose :weight, documentation: { desc: Bean::Variant.human_attribute_name(:weight) }
    expose :cost_price, documentation: { desc: Bean::Variant.human_attribute_name(:cost_price) }
    expose :origin_price, documentation: { desc: Bean::Variant.human_attribute_name(:origin_price) }
    expose :is_active, documentation: { desc: Bean::Variant.human_attribute_name(:is_active) }
  end

  class Variant < SimpleVariant
    expose :option_value_ids, documentation: { desc: Bean::Variant.human_attribute_name(:option_value_ids), type: Array[Integer] }
    expose :count_on_hand, documentation: { desc: Bean::StockLocationItem.human_attribute_name(:count_on_hand) }
    expose :option_values, using: AdminAPI::Entities::Bean::SimpleOptionValue
    expose :sales_volume, documentation: { desc: Bean::Variant.human_attribute_name(:sales_volume), type: Integer }
  end

  class VariantDetail < Variant
  end
end
