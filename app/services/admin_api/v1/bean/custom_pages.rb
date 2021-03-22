# frozen_string_literal: true

class AdminAPI::V1::Bean::CustomPages < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, :destroy do
    helpers do
      params :index_params do
        optional :title_cont, @api.resource_entity.documentation[:title]
        optional :slug_cont, @api.resource_entity.documentation[:slug]
      end

      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :title,
          :slug
        )
        optional :configs, type: String, desc: "页面设置"
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :title,
          :slug,
        )
        optional :configs, type: String, desc: "页面设置"
      end

      def end_of_association_chain
        @end_of_association_chain ||= resource_class.draft
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(target: current_application))
      end

      def create_api
        authorize! :create, build_resource

        run_member_action(:create_with_formal_custom_page)
      end
    end # helpers

    route_param :id, type: Integer do
      post "publish" do
        authorize! :publish, resource

        formal_resource = resource.formal_resource

        if formal_resource.update(formal_resource.draft_custom_page.dup_attributes)
          response_success
        else
          response_record_error(formal_resource)
        end
      end

      post "rollback_data" do
        authorize_and_run_member_action(:rollback_data)
      end
    end
  end # apis
end
