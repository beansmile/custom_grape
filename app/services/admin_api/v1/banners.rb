# frozen_string_literal: true
class AdminAPI::V1::Banners < API
  include Grape::Kaminari

  apis [:index, :show, :create, :update, :destroy] do
    helpers do
      params :index_params do
        optional :kind_eq
        optional :page_position_eq
        optional :application_id_eq
      end

      params :create_params do
        requires :all, using: AdminAPI::Entities::BannerDetail.documentation.slice(:page_position, :kind, :image)
        optional :all, using: AdminAPI::Entities::BannerDetail.documentation.slice(:position, :alt)
        optional :target, type: JSON, desc: "目标", documentation: { param_type: "body" } do
          optional :url
        end
      end

      params :update_params do
        optional :all, using: AdminAPI::Entities::BannerDetail.documentation.slice(:position, :page_position, :kind, :image, :alt)
        optional :target, type: JSON, desc: "目标", documentation: { param_type: "body" } do
          optional :url
        end
      end

      def build_resource
        @resource = end_of_association_chain.new(
          resource_params.merge(
            application: current_application
          )
        )
      end
    end
  end
end
