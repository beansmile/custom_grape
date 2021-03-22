# frozen_string_literal: true

class AdminAPI::V1::Bean::Shipments < API
  include Grape::Kaminari

  apis :index, :show, {
    # resource_class: Bean::Shipment,
    # collection_entity: AdminAPI::Entities::Shipment,
    # resource_entity: AdminAPI::Entities::ShipmentDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :order,
    # namespace: :shipments
  } do
    helpers do

      def includes
        [:order, :address, :stock_location]
      end

      params :index_params do
        requires :order_id_eq, @api.resource_entity.documentation[:order_id]
      end
    end # helpers

    route_param :id do
      desc "发货"
      params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :number
        )
      end
      put :ship do
        authorize_and_run_member_action(:ship, {}, number: params[:number])
      end
    end # apis
  end
end
