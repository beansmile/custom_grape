# frozen_string_literal: true

module Bean
  class StoreVariant < ApplicationRecord
    # constants
    BASE_PATH = "pages/products/detail"

    # concerns

    # attr related macros
    delegate :product, :product_id, :product_name, :product_images, :product_detail_images, :description, :option_values, :weight, to: :variant
    delegate :name, to: :variant, prefix: true

    # association macros
    belongs_to :store, class_name: "Bean::Store"
    belongs_to :variant, class_name: "Bean::Variant"

    has_many :shopping_cart_items, class_name: "Bean::ShoppingCartItem", dependent: :restrict_with_error
    has_many :line_items, class_name: "Bean::LineItem", dependent: :restrict_with_error

    # validation macros
    validates :cost_price, numericality: { greater_than: 0 }
    validates :origin_price, numericality: { greater_than_or_equal_to: 0 }

    # callbacks

    # other macros

    # scopes
    scope :same_store, -> (store) { where(store: store) }
    scope :same_product, -> (product) { joins(:variant).where(bean_variants: { id: product.variant_ids }) }
    scope :master, -> { where(is_master: true) }

    # class methods

    # instance methods
    def active?
      is_active? && store.active? && variant.active?
    end

    def in_stock?
      count_on_hand > 0
    end

    def count_on_hand
      @count_on_hand ||= store.stock_locations.joins(:stock_location_items).where(bean_stock_locations: { is_active: true }, bean_stock_location_items: { variant_id: variant_id }).sum("bean_stock_location_items.count_on_hand")
    end

    def other_store_variants
      @other_store_variants ||= self.class.same_store(store).same_product(product)
    end

    def mini_program_path_name
      product_name
    end

    def mini_program_path
      "#{BASE_PATH}?id=#{id}"
    end
  end
end
