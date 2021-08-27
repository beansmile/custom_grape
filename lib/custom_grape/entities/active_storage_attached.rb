require "grape-entity"

module CustomGrape::Entities
  class ActiveStorageAttached < Grape::Entity
    expose :service_url, as: :url, documentation: { desc: "Url" }
    expose :signed_id, documentation: { desc: "Signed ID" }
    expose :content_type, documentation: { desc: "Content type" }
    expose :filename, documentation: { desc: "Filename" }
    expose :byte_size, documentation: { desc: "Byte size" }
  end
end
