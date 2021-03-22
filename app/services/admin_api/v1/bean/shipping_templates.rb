# frozen_string_literal: true

class AdminAPI::V1::Bean::ShippingTemplates < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy do
    helpers do
      params :index_params do
        optional :name_cont, @api.resource_entity.documentation[:name]
        optional :calculate_type_eq, @api.resource_entity.documentation[:calculate_type]
        optional :merchant_id_eq, @api.resource_entity.documentation[:merchant]
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :name
        )
        requires :shipping_categories_attributes, type: Array[JSON] do
          requires :all, using: AdminAPI::Entities::Bean::ShippingCategory.documentation.slice(
            :name,
            :company_code
          )
          requires :shipping_methods_attributes, type: Array[JSON] do
            requires :calculator_attributes, type: JSON do
              # 暂时只支持一种calculator
              optional :type, default: "Bean::Calculator::Shipping::Weight"
              requires :preferences, type: JSON do
                requires :first_weight, type: Float, desc: "首重量(kg)"
                requires :first_weight_price, type: Float, desc: "首费(元)"
                requires :continued_weight, type: Float, desc: "续重量(kg)"
                requires :continued_weight_price, type: Float, desc: "续费(元)"
              end
            end
          end
        end
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :name,
        )
        optional :shipping_categories_attributes, type: Array[JSON] do
          optional :id
          optional :all, using: AdminAPI::Entities::Bean::ShippingCategory.documentation.slice(
            :name
          )
          optional :shipping_methods_attributes, type: Array[JSON] do
            optional :id
            optional :calculator_attributes, type: JSON do
              optional :id
              optional :preferences, type: JSON do
                optional :first_weight, type: Float, desc: "首重量(kg)"
                optional :first_weight_price, type: Float, desc: "首费(元)"
                optional :continued_weight, type: Float, desc: "续重量(kg)"
                optional :continued_weight_price, type: Float, desc: "续费(元)"
              end
            end
          end
        end
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge({ merchant: current_merchant }))
      end
    end # helpers
  end # apis
end
