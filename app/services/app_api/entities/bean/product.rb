# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleProduct < ::Entities::Model
    expose :name
    expose :share_title
    expose_attached :share_image
    expose_attached :poster_image
  end

  class Product < SimpleProduct
  end

  class ProductDetail < Product
    expose :description
  end
end
