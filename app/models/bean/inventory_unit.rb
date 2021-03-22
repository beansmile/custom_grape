# frozen_string_literal: true

module Bean
  class InventoryUnit < ApplicationRecord

    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :store_variant, class_name: "Bean::StoreVariant"
    belongs_to :order, class_name: "Bean::Order"
    belongs_to :shipment, class_name: "Bean::Shipment"
    belongs_to :line_item, class_name: "Bean::LineItem"

    # validation macros

    # callbacks
    before_validation :set_order

    # other macros

    # scopes

    # class methods
    def self.split(original_inventory_unit, extract_quantity)
      split = original_inventory_unit.dup
      split.line_item = original_inventory_unit.line_item
      split.quantity = extract_quantity
      original_inventory_unit.quantity -= extract_quantity
      split
    end

    # instance methods
    def required_quantity
      @required_quantity ||= line_item.quantity
      # return @required_quantity unless @required_quantity.nil?

      # @required_quantity = if exchanged_unit?
                             # original_return_item.return_quantity
                           # else
                             # line_item.quantity
                           # end
    end

    protected
    def set_order
      self.order = line_item.order
    end
  end
end
