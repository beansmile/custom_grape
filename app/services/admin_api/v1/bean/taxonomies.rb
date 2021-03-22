# frozen_string_literal: true

class AdminAPI::V1::Bean::Taxonomies < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy do
    helpers do
      params :index_params do
        optional :name_cont, @api.resource_entity.documentation[:name]
        optional :merchant_id_eq, @api.resource_entity.documentation[:merchant]
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :name,
          :taxonomy_type
        )
        optional :all, using: @api.resource_entity.documentation.slice(
          :position
        )
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :name,
          :position,
          :taxonomy_type
        )
      end

      def default_order
        "position asc, created_at asc"
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(merchant: current_merchant))
      end
    end # helpers
  end # apis
end
