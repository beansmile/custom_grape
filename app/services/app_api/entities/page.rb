# frozen_string_literal: true
module AppAPI::Entities
  class SimplePage < ::Entities::Model
    expose :content
    expose :title
    expose :slug
    expose :views_count
  end

  class Page < SimplePage
  end

  class PageDetail < Page
  end
end
