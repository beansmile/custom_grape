# frozen_string_literal: true
module AdminAPI::Entities
  class SimpleBanner < ::Entities::Model
    expose :target, documentation: { type: Hash }
    expose :position
    expose :page_position
    expose :kind
    expose :alt
    expose :application_id
  end

  class Banner < SimpleBanner
    expose_attached :image
  end

  class BannerDetail < Banner
  end
end
