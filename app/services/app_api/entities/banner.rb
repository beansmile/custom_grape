# frozen_string_literal: true
module AppAPI::Entities
  class SimpleBanner < ::Entities::Model
    expose :kind
    expose :target
    expose :position
    expose :page_position
    expose :alt
  end

  class Banner < SimpleBanner
    expose_attached :image
  end

  class BannerDetail < Banner
  end
end
