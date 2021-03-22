# frozen_string_literal: true

class AppAPI::V1::Bean::CustomVariantLists < API
  apis :show do
    desc "支付成功后的自定义商品列表", {
      success: resource_entity
    }
    get "success_pay" do
      @resource = current_application.custom_variant_lists.success_pay.first

      authorize_and_response_resource
    end
  end # apis
end
