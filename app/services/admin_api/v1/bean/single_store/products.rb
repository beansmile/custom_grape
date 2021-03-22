# frozen_string_literal: true

class AdminAPI::V1::Bean::SingleStore::Products < API
  include Grape::Kaminari

  apis :index, :show, :create, :update do
    helpers do
      params :create_params do
        requires :all, using: @api.resource_entity.documentation.slice(
          :name,
          :shipping_template_id,
          :taxon_ids,
        )
        requires :images, type: Array[String]
        requires :detail_images, type: Array[String]
        optional :all, using: @api.resource_entity.documentation.slice(
          :available_on,
          :discontinue_on,
          :description,
          :option_type_ids,
          :share_title,
          :share_image,
          :poster_image
        )
        optional :variants_attributes, type: Array[JSON] do
          optional :all, using: AdminAPI::Entities::Bean::SingleStore::Variant.documentation.slice(
            :sku,
            :weight,
            :cost_price,
            :origin_price,
            :count_on_hand,
            :is_active,
            :weight,
            :option_value_ids,
          )
        end
      end

      params :update_params do
        optional :all, using: @api.resource_entity.documentation.slice(
          :name,
          :shipping_template_id,
          :taxon_ids,
          :option_type_ids,
          :available_on,
          :discontinue_on,
          :description,
          :share_title,
          :share_image,
          :poster_image
        )
        optional :images, type: Array[String]
        optional :detail_images, type: Array[String]
        optional :variants_attributes, type: Array[JSON] do
          optional :all, using: AdminAPI::Entities::Bean::SingleStore::Variant.documentation.slice(
            :id,
            :sku,
            :weight,
            :cost_price,
            :origin_price,
            :count_on_hand,
            :is_active,
            :weight,
            :option_value_ids,
          )
        end
      end

      def collection
        return @collection if @collection

        search = Bean::Product.accessible_by(current_ability).ransack(ransack_params)

        search.sorts = "#{params[:order].keys.first} #{params[:order].values.first}" if params[:order].present?

        @collection = search.result(distinct: true).order("id DESC")
      end

      def product
        @product ||= Bean::Product.find(params[:id])
      end

      def resource
        @resource ||= Bean::SingleStore::Product.new(product: product)
      end

      def build_product
        @product = Bean::Product.new(merchant_id: current_merchant.id)
      end

      def build_resource
        @resource = Bean::SingleStore::Product.new(product: build_product, merchant_id: current_merchant.id)
        @resource.assign_attributes(resource_params.merge(merchant_id: current_merchant.id))

        @resource
      end

      def present_collection
        @present_collection ||= (params[:page] == 0 ? collection : paginate(collection)).map { |object| Bean::SingleStore::Product.new(product: object) }
      end

      def auth_resource
        @auth_resource ||= product
      end

      def auth_resource_class
        @auth_resource_class ||= Bean::Product
      end
    end
  end
end
