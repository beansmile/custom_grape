# frozen_string_literal: true
class AdminAPI::V1::ActiveStorage::Blobs < API
  include Grape::Kaminari

  apis [:index, :show, :update, :destroy] do
    helpers do
      def resource_class
        ActiveStorage::Blob
      end

      params :index_params do
        optional :filename_cont, type: String, desc: "文件名"
        optional :content_type_cont, type: String, desc: "文件类型"
        optional :tags_name_in, type: Array[String], desc: "标签"
      end

      params :update_params do
        optional :filename, type: String, desc: "文件名"
        optional :tag_list, type: Array[String], desc: "标签"
      end

      def destroy_api
        if resource.attachments.exists?
          response_error("资源已经被使用，不可删除")
        else
          super
        end
      end
    end
  end
end
