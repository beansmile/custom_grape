# frozen_string_literal: true

class AppAPI::V1::Bean::ShoppingCartItems < API
  apis :create, :update, :destroy, {
    # resource_class: Bean::ShoppingCartItem,
    # collection_entity: AppAPI::Entities::ShoppingCartItem,
    # resource_entity: AppAPI::Entities::ShoppingCartItemDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :store_variant_id,
        )
        optional :all, using: @api.resource_entity.documentation.slice(
          :quantity
        )
      end

      params :update_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :quantity
        )
      end

      def create_api
        authorize! :create, resource_class

        @resource = resource_class.add_to_cart(shopping_cart: current_user.shopping_cart, store_variant_id: params[:store_variant_id], quantity: params[:quantity])

        if @resource.errors.full_messages.empty?
          response_resource
        else
          response_record_error(resource)
        end
      end

      def update_api
        authorize_and_run_member_action(:update_item, { auth_action: :update }, quantity: params[:quantity])
      end
    end # helpers
  end # apis
end
