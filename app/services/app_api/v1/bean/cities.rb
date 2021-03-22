# frozen_string_literal: true

class AppAPI::V1::Bean::Cities < API
  include Grape::Kaminari

  apis :index do
    helpers do
      params :index_params do
        optional :code_cont, @api.resource_entity.documentation[:code]
        optional :name_cont, @api.resource_entity.documentation[:name]
        optional :province_id_eq, @api.resource_entity.documentation[:province]
      end
    end # helpers
  end # apis
end
