# frozen_string_literal: true

class AdminAPI::V1::Bean::OptionTypes < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy, {
    # resource_class: Bean::OptionType,
    # collection_entity: AdminAPI::Entities::OptionType,
    # resource_entity: AdminAPI::Entities::OptionTypeDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :index_params do
        optional :name_cont, @api.resource_entity.documentation[:name]
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :name
        )
        optional :option_values_attributes, type: Array[JSON] do
          requires :all, using: AdminAPI::Entities::Bean::OptionValue.documentation.slice(
            :name
          )
        end
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :name,
        )
        optional :option_values_attributes, type: Array[JSON] do
          optional :all, using: AdminAPI::Entities::Bean::OptionValue.documentation.slice(
            :id,
            :name,
          )
          optional :_destroy
        end
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(merchant_id: current_merchant.id))
      end
    end # helpers
  end # apis
end
