# frozen_string_literal: true

module Bean
  module Stock
    class Adjuster
      # constants

      # concerns

      # attr related macros
      attr_accessor :required_quantity, :received_quantity

      # association macros

      # validation macros

      # callbacks

      # other macros

      # scopes

      # class methods

      # instance methods
      def initialize(inventory_unit)
        self.required_quantity = inventory_unit.required_quantity
        self.received_quantity = 0
      end

      def adjust(package_to_adjust, item)
        if fulfilled?
          package_to_adjust.remove_item item
        else
          if item.quantity >= remaining_quantity
            item.quantity = remaining_quantity
          end
          self.received_quantity += item.quantity
        end
      end

      def fulfilled?
        remaining_quantity.zero?
      end

      def remaining_quantity
        required_quantity - received_quantity
      end
    end
  end
end
