# frozen_string_literal: true
module AdminAPI::Entities
  class SimpleStaticPage < ::Entities::Model
    expose :title
    expose :slug
    expose :status
    expose :views_count
    expose_attached :wxacode
  end

  class StaticPage < SimpleStaticPage
  end

  class StaticPageDetail < StaticPage
    expose :content
  end
end
