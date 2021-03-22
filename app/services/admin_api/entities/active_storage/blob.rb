# frozen_string_literal: true
module AdminAPI::Entities::ActiveStorage
  class Blob < CustomGrape::Entities::ActiveStorageAttached
    expose :id
    expose :created_at
    expose :custom_tag_list, as: :tag_list
  end
end
