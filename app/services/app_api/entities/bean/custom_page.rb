# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleCustomPage < ::Entities::Model
    expose :title
    expose :slug
  end

  class CustomPage < SimpleCustomPage
  end

  class CustomPageDetail < CustomPage
    expose :configs
    # TODO 新自定义页面组件完成后再调整这里的逻辑
    # expose :custom_variant_lists, using: CustomVariantList do |obj, _|
      # custom_variant_list_ids = obj.components.select { |c| c["name"] == "custom-product-list" }
        # .map { |c_p_l| c_p_l.dig("data", "data") }.flatten
        # .map { |data| data["id"] }
      # ::Bean::CustomVariantList.where(id: custom_variant_list_ids)
    # end
  end
end
