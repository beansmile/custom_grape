# frozen_string_literal: true

module Bean
  class ShippingTemplate < ApplicationRecord
    # constants

    # concerns

    # attr related macros
    enum calculate_type: {
      weight: 0
      # 其他计费方式暂不处理
    }

    default_value_for :calculate_type, :weight

    # association macros
    belongs_to :merchant, class_name: "Bean::Merchant"

    has_many :products, class_name: "Bean::Product", dependent: :restrict_with_error
    has_many :shipping_categories, class_name: "Bean::ShippingCategory", dependent: :destroy

    accepts_nested_attributes_for :shipping_categories

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
