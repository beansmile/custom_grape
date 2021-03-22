# frozen_string_literal: true

class AppAPI::V1::Bean::Orders < API
  include Grape::Kaminari

  apis [:create, :index, :show] do
    helpers do
      params :create_params do
        requires :line_items_attributes, type: Array[JSON] do
          requires :all, using: AppAPI::Entities::Bean::LineItem.documentation.slice(
            :quantity,
            :store_variant_id
          )
        end
        optional :all, using: @api.resource_entity.documentation.slice(
          :user_remark,
          :address_id,
          :order_source_type
        )
      end

      params :index_params do
        optional :state_eq, @api.resource_entity.documentation[:state]
        optional :state_in, type: Array[String], documentation: @api.resource_entity.documentation[:state]
        optional :shipment_state_eq, @api.resource_entity.documentation[:shipment_state]
        optional :shipment_state_in, type: Array[String], documentation: @api.resource_entity.documentation[:shipment_state]
        optional :shipments_state_eq, documentation: AppAPI::Entities::Bean::Shipment.documentation[:state]
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(user: current_user))
      end

      def create_api
        build_resource

        authorize_and_run_member_action(:generate, auth_action: :create)
      end

    end # helpers


    desc "预览订单", {
      success: AppAPI::Entities::Bean::PreviewOrder
    }
    params do
      requires :line_items_attributes, type: Array[JSON] do
        requires :all, using: AppAPI::Entities::Bean::LineItem.documentation.slice(
          :quantity,
          :store_variant_id
        )
      end
      optional :all, using: @api.resource_entity.documentation.slice(
        :user_remark,
        :address_id,
        :order_source_type
      )
    end
    post "preview" do
      authorize! :preview, resource_class

      build_resource

      @resource.preview
      @resource_entity ||= AppAPI::Entities::Bean::PreviewOrder

      response_resource
    end

    route_param :id do
      desc "获取支付参数", {
      detail: <<-NOTES.strip_heredoc
         ```json
         {
           "appId": "",
           "package": "prepay_id=wx3015162450394482e7a10b052399580378",
           "nonceStr": "qfMB0RjwTl7BNC3L",
           "timeStamp": "1535613384",
           "signType": "MD5",
           "paySign": "162B8FC6F32B957C91D101AC09F44BA8"
         }
         ```
        NOTES
      }
      params do
        requires :payment_method_id, type: Integer
      end
      post "request_payment" do
        authorize! :request_payment, resource
        if resource.init?
          payment_method = current_application.payment_methods.find_by(id: params[:payment_method_id])
          resource.ip_address = ip_address
          payment = resource.payments.create({
            payment_method: payment_method,
            amount: resource.total,
            payment_type: "charge",
            paymentable: resource,
            order_id: resource.id
          })

          response = payment_method.process(payment)

          present response
        else
          error!("订单已经过期!")
        end
      end

      desc "申请退款", {
        success: AppAPI::Entities::Bean::OrderDetail
      }
      params do
        optional :apply_reason, type: String, desc: "退款原因"
      end
      put "apply_refund" do
        authorize_and_run_member_action(:apply_refund, {}, apply_reason: params[:apply_reason])
      end

      desc "取消订单", {
        summary: "取消订单",
        success: resource_entity
      }
      delete :close do
        authorize_and_run_member_action(:perform_aasm_event, { auth_action: :close }, :close)
      end

      desc "确认收货", {
        summary: "确认收货",
        success: resource_entity
      }
      put :receive do
        authorize_and_run_member_action(:perform_aasm_event, { auth_action: :receive }, :receive)
      end
    end
  end # apis
end
