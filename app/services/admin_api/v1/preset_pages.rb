# frozen_string_literal: true
class AdminAPI::V1::PresetPages < API
  include Grape::Kaminari

  apis [:index, :show, :update] do
    helpers do
      params :index_params do
        optional :title_cont
      end

      params :update_params do
        optional :all, using: AdminAPI::Entities::StaticPageDetail.documentation.slice(:content, :title)
      end
    end
  end
end
