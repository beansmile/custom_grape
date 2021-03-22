# frozen_string_literal: true

module Bean
  module Stock
    class ContentItem

      # constants

      # concerns

      # attr related macros
      attr_accessor :inventory_unit

      # association macros

      # validation macros

      # callbacks

      # other macros

      # scopes

      # class methods

      # instance methods

      def initialize(inventory_unit)
        @inventory_unit = inventory_unit
      end

      with_options allow_nil: true do
        delegate :line_item,
          :quantity,
          :store_variant, to: :inventory_unit
        delegate :cost_price, to: :store_variant
        delegate :weight, to: :store_variant, prefix: true
      end

      def weight
        store_variant_weight * quantity
      end

      def quantity=(value)
        @inventory_unit.quantity = value
      end

      def amount
        price * quantity
      end
    end
  end
end
