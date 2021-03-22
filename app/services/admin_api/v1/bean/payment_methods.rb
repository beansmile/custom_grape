# frozen_string_literal: true

class AdminAPI::V1::Bean::PaymentMethods < API
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

      def resource_params
        raw_params = ActionController::Parameters.new(params).permit(permitted_params)
        if params[:apiclient_cert]
          raw_params[:apiclient_cert] = ActionDispatch::Http::UploadedFile.new params[:apiclient_cert]
        end
        raw_params
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :type,
          :name
        )
        optional :is_active, using: @api.resource_entity.documentation.slice(:is_active)
        optional :apiclient_cert, type: File
        requires :configuration, type: JSON do
          requires :mch_id, type: String
          requires :mch_key, type: String
        end
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :type,
          :name,
          :is_active
        )
        optional :apiclient_cert, type: File
        optional :configuration, type: JSON do
          optional :mch_id, type: String
          optional :mch_key, type: String
        end
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(application_id: current_application.id))
      end
    end # helpers
  end # apis
end
