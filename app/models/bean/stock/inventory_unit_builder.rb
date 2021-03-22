# frozen_string_literal: true

module Bean
  module Stock
    class InventoryUnitBuilder

      # constants

      # concerns

      # attr related macros

      # association macros

      # validation macros

      # callbacks

      # other macros

      # scopes

      # class methods

      # instance methods
      def initialize(order)
        @order = order
      end

      def units
        @order.line_items.map do |line_item|
          # They go through multiple splits, avoid loading the
          # association to order until needed.
          Bean::InventoryUnit.new(
            line_item: line_item,
            store_variant_id: line_item.store_variant_id,
            quantity: line_item.quantity,
            order_id: @order.id
          )
        end
      end
    end
  end
end
