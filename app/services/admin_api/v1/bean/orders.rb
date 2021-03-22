# frozen_string_literal: true

class AdminAPI::V1::Bean::Orders < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy do
    helpers do
      params :index_params do
        optional :number_cont, documentation: @api.resource_entity.documentation[:number]
        optional :state_eq, documentation: @api.resource_entity.documentation[:state]
        optional :shipment_state_eq, documentation: @api.resource_entity.documentation[:shipment_state]
        optional :shipment_state_in, type: Array[String], documentation: @api.resource_entity.documentation[:shipment_state]
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :admin_user_remark
        )
      end
    end # helpers

    desc "导出订单列表"
    params do
      use :index_params
    end
    get "export" do
      export_xlsx(collection.map { |order| order.export_data }, ::Bean::Order.model_name)
    end

    route_param :id do
      desc "同意直接退款", {
        success: AdminAPI::Entities::Bean::OrderDetail
      }
      put "agree_refund" do
        authorize_and_run_member_action(:perform_aasm_event, { auth_action: :audit_refund }, :agree_refund)
      end

      desc "拒绝直接退款", {
        success: AdminAPI::Entities::Bean::OrderDetail
      }
      put "refuse_refund" do
        authorize_and_run_member_action(:perform_aasm_event, { auth_action: :audit_refund }, :refuse_refund)
      end

      desc "直接退款", {
        success: AdminAPI::Entities::Bean::OrderDetail
      }
      put "direct_refund" do
        authorize_and_run_member_action(:perform_aasm_event, { auth_action: :audit_refund }, :refund)
      end
    end
  end # apis
end
