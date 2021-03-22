# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleCustomVariantList < ::Entities::Model
    expose :remark
    expose :title
    expose :kind
    expose :store_variant_ids, documentation: { type: Array[Integer] }
  end

  class CustomVariantList < SimpleCustomVariantList
    expose :store_variants, using: StoreVariant
  end

  class CustomVariantListDetail < CustomVariantList
  end
end
