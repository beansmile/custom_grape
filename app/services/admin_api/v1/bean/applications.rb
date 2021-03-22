# frozen_string_literal: true

class AdminAPI::V1::Bean::Applications < API
  include Grape::Kaminari

  apis :index, :show, :create, :update, {
    # resource_class: Bean::Application,
    # collection_entity: AdminAPI::Entities::Application,
    # resource_entity: AdminAPI::Entities::ApplicationDetail,
    # find_by_key: :id
    # skip_authentication: false,
    # belongs_to: :category,
    # namespace: :mine
  } do
    helpers do
      params :index_params do
        optional :appid_eq, @api.resource_entity.documentation[:appid]
        optional :name_cont, @api.resource_entity.documentation[:name]
      end

      params :create_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :name,
          :contact,
          :company_name,
          :mobile,
          :share_title,
          :share_image
        )
        optional :hotwords, type: Array[String]
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :name,
          :contact,
          :company_name,
          :mobile,
          :share_title,
          :share_image
        )
        optional :hotwords, type: Array[String]
      end

      def build_resource
        @resource = end_of_association_chain.new(resource_params.merge(creator: current_user))
      end

      def create_api
        # 所有admin_user均可创建应用
        raise CanCan::AccessDenied unless current_user

        create_resource
      end
    end # helpers

    get :current do
      @resource = current_application

      response_resource
    end

    paginate
    get "list_without_authorize" do
      response_collection
    end

    route_param :id do
      desc "到期时间设置"
      params do
        optional :expired_at, type: DateTime
      end
      put :update_expired_at do
        authorize_and_run_member_action(:update_expired_at, {}, expired_at: params[:expired_at])
      end
    end
  end # apis
end
