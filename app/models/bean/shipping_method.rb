# frozen_string_literal: true

module Bean
  class ShippingMethod < ApplicationRecord
    # constants

    # concerns

    # attr related macros
    # 暂时只有一个运送方式
    default_value_for :is_default, true

    # association macros
    belongs_to :shipping_category, class_name: "Bean::ShippingCategory"

    has_one :calculator, as: :calculable, class_name: "Bean::Calculator", dependent: :destroy

    has_many :shipping_method_zones, class_name: "Bean::ShippingMethodZone", dependent: :destroy
    has_many :zones, through: :shipping_method_zones
    has_many :shipping_rates, class_name: "Bean::ShippingRate", dependent: :nullify

    accepts_nested_attributes_for :calculator

    # validation macros
    validate :check_is_default_unique

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def include?(address)
      return false unless address

      zones.includes(:zone_members).any? do |zone|
        zone.include?(address)
      end
    end

    private

    def check_is_default_unique
      order_default_count = shipping_category.shipping_methods.where.not(id: id).where(is_default: true).count
      errors.add(:base, "必须且只能存在一个默认的运送方式") unless is_default ? order_default_count == 0 : order_default_count == 1
    end
  end
end
