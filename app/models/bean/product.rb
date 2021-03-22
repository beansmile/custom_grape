# frozen_string_literal: true

module Bean
  class Product < ApplicationRecord
    # constants

    # concerns

    # attr related macros
    enum freight_calculation_type: {
      unified: 0, # 统一运费，多个商品都设置了统一运费，则使用值最大的
      template: 1 # 运费模板
    }, _suffix: true

    # association macros
    belongs_to :merchant, class_name: "Bean::Merchant"
    belongs_to :shipping_template, class_name: "Bean::ShippingTemplate"

    has_many :variants, class_name: "Bean::Variant", dependent: :destroy
    accepts_nested_attributes_for :variants, allow_destroy: true
    has_many :store_variants, through: :variants

    has_many :product_taxons, class_name: "Bean::ProductTaxon", dependent: :destroy
    has_many :taxons, through: :product_taxons
    has_many :product_option_types, class_name: "Bean::ProductOptionType", dependent: :destroy
    has_many :option_types, through: :product_option_types

    # validation macros
    validates :name, presence: true, uniqueness: { scope: :merchant_id }

    # callbacks

    # other macros
    has_one_attached :share_image
    has_one_attached :poster_image
    custom_has_many_attached :images
    custom_has_many_attached :detail_images

    # scopes

    # class methods

    # instance methods
    def main_image
      @main_image ||= images[0]
    end

    def active?
      (available_on.nil? || available_on <= Time.current) && not_discontinue_on && merchant.is_active?
    end

    def not_discontinue_on
      discontinue_on.nil? || discontinue_on > Time.current
    end

    def sales_volume
      @sales_volume ||= store_variants.sum(:sales_volume)
    end
  end
end
