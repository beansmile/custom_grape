# frozen_string_literal: true

class AppAPI::V1::Bean::StoreVariants < API
  include Grape::Kaminari

  apis :index, :show, {
    # resource_class: Bean::StoreVariant,
    # collection_entity: AppAPI::Entities::StoreVariant,
    # resource_entity: AppAPI::Entities::StoreVariantDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :index_params do
        optional :store_id_eq, @api.resource_entity.documentation[:store_id]
        optional :is_master_eq, @api.resource_entity.documentation[:is_master]
        optional :variant_product_id_eq, @api.resource_entity.documentation[:product_id]
        optional :variant_product_taxons_parent_id_eq, type: Integer, documentation: { desc: "一级分类ID" }
        optional :variant_product_taxons_id_eq, type: Integer, documentation: { desc: "二级分类ID" }
        optional :keyword, as: :variant_product_taxons_name_or_variant_product_name_cont, type: String, desc: "关键字：分类名或商品名"
      end
    end # helpers
  end # apis
end
