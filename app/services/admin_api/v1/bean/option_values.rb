# frozen_string_literal: true

class AdminAPI::V1::Bean::OptionValues < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy, {
    # resource_class: Bean::OptionValue,
    # collection_entity: AdminAPI::Entities::OptionValue,
    # resource_entity: AdminAPI::Entities::OptionValueDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :index_params do
        optional :name_cont, @api.resource_entity.documentation[:name]
        optional :option_type_id_eq, @api.resource_entity.documentation[:option_type]
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :name,
          :option_type_id
        )
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :name,
        )
      end
    end # helpers
  end # apis
end
