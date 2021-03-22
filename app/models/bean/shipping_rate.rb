# frozen_string_literal: true

module Bean
  class ShippingRate < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :shipment, class_name: "Bean::Shipment"
    belongs_to :shipping_method, class_name: "Bean::ShippingMethod"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
