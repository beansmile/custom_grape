# frozen_string_literal: true

module Bean
  class ShippingCategory < ApplicationRecord
    # constants

    # concerns

    # attr related macros
    # 暂时只有一种分类
    default_value_for :name, "快递"

    # association macros
    belongs_to :shipping_template, class_name: "Bean::ShippingTemplate"

    has_many :shipping_methods, inverse_of: :shipping_category, class_name: "Bean::ShippingMethod", dependent: :destroy

    accepts_nested_attributes_for :shipping_methods

    # validation macros
    validates :name, presence: true, uniqueness: { scope: :shipping_template_id }

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
