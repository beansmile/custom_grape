# frozen_string_literal: true

module Bean
  module Stock
    class Packer

      # constants

      # concerns

      # attr related macros
      attr_reader :stock_location, :inventory_units, :splitters

      # association macros

      # validation macros

      # callbacks

      # other macros

      # scopes

      # class methods

      # instance methods

      def initialize(stock_location, inventory_units, splitters = [Splitter::Base])
        @stock_location = stock_location
        @inventory_units = inventory_units
        @splitters = splitters
      end

      def packages
        if splitters.empty?
          [default_package]
        else
          build_splitter.split [default_package]
        end
      end

      def default_package
        package = Package.new(stock_location)

        # Group by variant_id as grouping by variant fires cached query.
        inventory_units.index_by { |unit| unit.store_variant.variant_id }.each do |variant_id, inventory_unit|
          variant = Bean::Variant.find(variant_id)
          unit = inventory_unit.dup # Can be used by others, do not use directly
          unit.line_item = inventory_unit.line_item

          if variant.track_inventory?
            next unless stock_location.stocks? variant

            on_hand = stock_location.stock_location_items.find_by(variant: variant).count_on_hand

            package.add(InventoryUnit.split(unit, on_hand)) if on_hand.positive?
          else
            package.add unit
          end
        end

        package
      end

      private

      def build_splitter
        splitter = nil
        splitters.reverse_each do |klass|
          splitter = klass.new(self, splitter)
        end
        splitter
      end
    end
  end
end
