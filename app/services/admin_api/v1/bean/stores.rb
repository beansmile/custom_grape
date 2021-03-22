# frozen_string_literal: true

class AdminAPI::V1::Bean::Stores < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy, {
    # resource_class: Bean::Store,
    # collection_entity: AdminAPI::Entities::Store,
    # resource_entity: AdminAPI::Entities::StoreDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :index_params do
        optional :name_cont, @api.resource_entity.documentation[:name]
        optional :merchant_id_eq, @api.resource_entity.documentation[:merchant]
        optional :active_eq, @api.resource_entity.documentation[:active]
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :name
        )
        optional :all, using: @api.resource_entity.documentation.slice(:discontinue_on)
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :name,
          :active,
          :discontinue_on
        )
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(merchant_id: current_merchant&.id))
      end
    end # helpers

    paginate
    get "list_without_authorize" do
      response_collection
    end
  end # apis
end
