# frozen_string_literal: true

module AdminAPI::Entities
  class SimplePage < ::Entities::Model
    expose :slug
    expose :title
    expose :type
    expose :application_id
    expose :status
    expose :views_count
  end

  class Page < SimplePage
    expose_attached :wxacode
  end

  class PageDetail < Page
    expose :content
  end
end
