# frozen_string_literal: true

class AppAPI::V1::Bean::Addresses < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy do
    helpers do
      params :index_params do
        optional :detail_info_cont, @api.resource_entity.documentation[:detail_info]
        optional :postal_code_cont, @api.resource_entity.documentation[:postal_code]
        optional :receiver_name_cont, @api.resource_entity.documentation[:receiver_name]
        optional :tel_number_cont, @api.resource_entity.documentation[:tel_number]
        optional :city_id_eq, @api.resource_entity.documentation[:city]
        optional :country_id_eq, @api.resource_entity.documentation[:country]
        optional :district_id_eq, @api.resource_entity.documentation[:district]
        optional :province_id_eq, @api.resource_entity.documentation[:province]
        optional :user_id_eq, @api.resource_entity.documentation[:user]
        optional :is_default_eq, @api.resource_entity.documentation[:is_default]
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :city_id,
          :country_id,
          :district_id,
          :province_id,
          :detail_info,
          :postal_code,
          :receiver_name,
          :tel_number,
        )
        optional :all, using: @api.resource_entity.documentation.slice(
          :is_default
        )
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :detail_info,
          :postal_code,
          :receiver_name,
          :tel_number,
          :city_id,
          :country_id,
          :district_id,
          :province_id,
          :is_default
        )
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(user: current_user))
      end

      def default_order
        @default_order ||= "is_default DESC"
      end
    end # helpers
  end # apis
end
