# frozen_string_literal: true
class AppAPI::V1::Pages < API
  apis [:show] do
    helpers do
      def resource
        @resource ||= current_application.pages.friendly.find params[:id]
      end

      def show_api
        authorize_and_response_resource

        resource.increment!(:views_count)
      end
    end
  end
end
