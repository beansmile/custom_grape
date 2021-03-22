# frozen_string_literal: true
class AdminAPI::V1::StaticPages < API
  include Grape::Kaminari

  apis [:index, :show, :create, :update, :destroy] do
    helpers do
      params :index_params do
        optional :title_cont
      end

      params :create_params do
        requires :all, using: AdminAPI::Entities::StaticPageDetail.documentation.slice(:content, :title, :status)
      end

      params :update_params do
        optional :all, using: AdminAPI::Entities::StaticPageDetail.documentation.slice(:content, :title, :status)
      end
    end

    route_param :id do
      desc "发布" do
        success ::AdminAPI::Entities::StaticPageDetail
      end
      put "publish" do
        authorize_and_run_member_action(:publish, auth_action: :update)
      end

      desc "存草稿" do
        success ::AdminAPI::Entities::StaticPageDetail
      end
      put "save_as_draft" do
        authorize_and_run_member_action(:save_as_draft, auth_action: :update)
      end
    end
  end
end
