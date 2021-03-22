# frozen_string_literal: true

class AppAPI::V1::Bean::Taxons < API
  include Grape::Kaminari

  apis :index do
    helpers do
      params :index_params do
        optional :name_cont, @api.resource_entity.documentation[:name]
        optional :parent_id_eq, @api.resource_entity.documentation[:parent]
        optional :taxonomy_taxonomy_type_eq, type: String, default: "category"
        optional :parent_id_null, type: Grape::API::Boolean
      end

      def default_order
        "position asc, created_at asc"
      end
    end # helpers
  end # apis
end
