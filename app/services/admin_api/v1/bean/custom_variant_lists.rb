# frozen_string_literal: true

class AdminAPI::V1::Bean::CustomVariantLists < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy, {
    # resource_class: Bean::CustomVariantList,
    # collection_entity: AdminAPI::Entities::CustomVariantList,
    # resource_entity: AdminAPI::Entities::CustomVariantListDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :index_params do
        optional :remark_cont, @api.resource_entity.documentation[:remark]
        optional :title_cont, @api.resource_entity.documentation[:title]
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :title
        )
        optional :all, using: @api.resource_entity.documentation.slice(
          :remark,
          :store_variant_ids
        )
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :remark,
          :title,
          :store_variant_ids
        )
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(target: current_application))
      end
    end # helpers
  end # apis
end
