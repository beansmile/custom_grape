# frozen_string_literal: true

class AdminAPI::V1::Bean::ExpressServices < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy, {
    # resource_class: Bean::PaymentMethod,
    # collection_entity: AdminAPI::Entities::PaymentMethod,
    # resource_entity: AdminAPI::Entities::PaymentMethodDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :payment,
    # namespace: :applications
  } do
    helpers do

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :type,
          :name
        )
        optional :is_active, using: @api.resource_entity.documentation.slice(:is_active)
        requires :configs, type: JSON do
          requires :key, type: String
          requires :customer, type: String
          requires :salt, type: String
        end
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :type,
          :name,
          :is_active
        )
        optional :configs, type: JSON do
          optional :key, type: String
          optional :customer, type: String
          optional :salt, type: String
        end
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(application_id: current_application.id))
      end
    end # helpers
  end # apis
end

