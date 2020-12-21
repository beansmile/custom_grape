require "grape-entity"

module CustomGrape::Entities
  class ActiveStorageAttached < Grape::Entity
    expose :service_url, as: :url
    expose :signed_id
    expose :content_type
    expose :filename
    expose :byte_size
  end
end
