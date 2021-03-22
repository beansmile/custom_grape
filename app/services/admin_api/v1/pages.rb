# frozen_string_literal: true

class AdminAPI::V1::Pages < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy, {
    resource_class: Page,
    collection_entity: AdminAPI::Entities::Page,
    resource_entity: AdminAPI::Entities::PageDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :index_params do
        optional :slug_cont, @api.resource_entity.documentation[:slug]
        optional :title_cont, @api.resource_entity.documentation[:title]
        optional :status_eq, @api.resource_entity.documentation[:status]
        optional :application_id_eq, @api.resource_entity.documentation[:application]
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :slug,
          :title,
          :content
        )
        optional :all, using: @api.resource_entity.documentation.slice(
          :type,
          :status
        )
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :slug,
          :title,
          :status,
          :content
        )
      end

      def build_resource
        @resource = end_of_association_chain.new(
          resource_params.merge(
            application: current_application,
            type: "StaticPage"
          )
        )
      end
    end # helpers

    route_param :id do
      desc "发布" do
        success ::AdminAPI::Entities::PageDetail
      end
      put "publish" do
        authorize_and_run_member_action(:publish, auth_action: :update)
      end

      desc "存草稿" do
        success ::AdminAPI::Entities::PageDetail
      end
      put "save_as_draft" do
        authorize_and_run_member_action(:save_as_draft, auth_action: :update)
      end
    end
  end # apis
end
