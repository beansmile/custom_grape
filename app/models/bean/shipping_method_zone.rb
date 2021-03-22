# frozen_string_literal: true

module Bean

  class ShippingMethodZone < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :zone, class_name: "Bean::Zone"
    belongs_to :shipping_method, class_name: "Bean::ShippingMethod"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
