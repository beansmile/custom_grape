# frozen_string_literal: true

class AppAPI::V1::Bean::CustomPages < API
  include Grape::Kaminari

  apis :show, {
    find_by_key: :slug
  } do
    helpers do
      def resource
        return @resource if @resource
        @resource = current_application.custom_pages.formal.includes(resource_includes).find_by!("#{find_by_key}" => params[find_by_key])
        @resource = @resource.draft_custom_page if params[:is_preview]
        @resource
      end
    end # helpers
  end # apis
end
