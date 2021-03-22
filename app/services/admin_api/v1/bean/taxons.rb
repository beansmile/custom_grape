# frozen_string_literal: true

class AdminAPI::V1::Bean::Taxons < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy do
    helpers do
      params :index_params do
        optional :name_cont, @api.resource_entity.documentation[:name]
        optional :parent_id_eq, @api.resource_entity.documentation[:parent]
        optional :taxonomy_id_eq, @api.resource_entity.documentation[:taxonomy]
        optional :taxonomy_name_cont
        optional :parent_id_null, type: Grape::API::Boolean
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :name
        )
        optional :all, using: @api.resource_entity.documentation.slice(
          :parent_id,
          :position,
          :icon
        )
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :name,
          :parent_id,
          :position,
          :icon
        )
      end

      def default_order
        "position asc, created_at asc"
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(taxonomy: current_merchant&.taxonomies&.category&.first))
      end
    end # helpers
  end # apis
end
