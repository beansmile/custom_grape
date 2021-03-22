# frozen_string_literal: true

module Bean
  class Variant < ApplicationRecord
    # constants

    # concerns

    # attr related macros
    delegate :name, :images, :detail_images, to: :product, prefix: true
    delegate :merchant, :description, to: :product

    # association macros
    belongs_to :product, class_name: "Bean::Product"

    has_many :option_value_variants, class_name: "Bean::OptionValueVariant", dependent: :destroy
    has_many :option_values, through: :option_value_variants
    has_many :store_variants, class_name: "Bean::StoreVariant", dependent: :destroy
    has_many :stock_location_items, class_name: "Bean::StockLocationItem", dependent: :destroy

    # validation macros
    validates :sku, presence: true, uniqueness: { scope: :product_id }

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def name
      @name ||= "#{product_name}（#{option_types_desc}）"
    end

    def option_types_desc
      @option_types_desc ||= option_values.order("option_type_id").map { |option_value| "#{option_value.option_type.name}：#{option_value.name}" }.join("；")
    end

    def active?
      product.active?
    end

    def sales_volume
      @sales_volume ||= store_variants.sum(:sales_volume)
    end
  end
end
