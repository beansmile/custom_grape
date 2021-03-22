# frozen_string_literal: true
class AppAPI::V1::Banners < API
  include Grape::Kaminari

  apis [:index] do
    helpers do
      def default_order
        @default_order ||= "position ASC"
      end

      params :index_params do
        optional :page_position_eq, AppAPI::Entities::BannerDetail.documentation[:page_position]
        optional :application_id_eq
      end
    end
  end
end
