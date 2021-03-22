# frozen_string_literal: true

module Bean
  class ShippingMethodCategory < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :shipping_method, class_name: "Bean::ShippingMethod"
    belongs_to :shipping_category, class_name: "Bean::ShippingCategory"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
