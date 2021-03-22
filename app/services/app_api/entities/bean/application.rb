# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleApplication < ::Entities::Model
    expose :share_title
    expose :hotwords
  end

  class Application < SimpleApplication
    expose_attached :share_image
  end

  class ApplicationDetail < Application
  end
end
