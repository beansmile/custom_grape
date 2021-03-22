# frozen_string_literal: true

class AdminAPI::V1::Bean::StoreVariants < API
  include Grape::Kaminari

  apis :index, :show, :update, {
    # resource_class: Bean::StoreVariant,
    # collection_entity: AdminAPI::Entities::StoreVariant,
    # resource_entity: AdminAPI::Entities::StoreVariantDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :index_params do
        optional :variant_id_eq, @api.resource_entity.documentation[:variant]
        optional :variant_product_id_eq, type: Integer
        optional :variant_product_name_cont, type: String
        optional :is_master_eq, type: Grape::API::Boolean
        optional :is_active_eq, @api.resource_entity.documentation[:is_active]
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :cost_price,
          :origin_price,
          :is_active,
        )
      end
    end # helpers
  end # apis
end
