# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleCustomVariantList < ::Entities::Model
    expose :remark
    expose :title
    expose :kind
    expose :store_variant_ids, documentation: { type: Array[Integer] }
  end

  class CustomVariantList < SimpleCustomVariantList
  end

  class CustomVariantListDetail < CustomVariantList
    expose :store_variants, using: StoreVariant
  end
end
