# frozen_string_literal: true

module Bean
  module Stock
    class Package
      # constants

      # concerns

      # attr related macros
      attr_reader :stock_location, :contents
      attr_accessor :shipping_rates

      # association macros

      # validation macros

      # callbacks

      # other macros

      # scopes

      # class methods

      # instance methods
      def initialize(stock_location, contents = [])
        @stock_location = stock_location
        @contents = contents
        @shipping_rates = []
      end

      def add(inventory_unit)
        # Remove find_item check as already taken care by prioritizer
        contents << ContentItem.new(inventory_unit)
      end

      def remove_item(item)
        @contents -= [item]
      end

      def quantity
        contents.sum(&:quantity)
      end

      def empty?
        quantity.zero?
      end

      def weight
        contents.sum(&:weight)
      end

      def shipping_templates
        Bean::ShippingTemplate.joins(products: :variants).
          where(bean_variants: { id: variant_ids }).distinct
      end

      def to_shipment
        Bean::Shipment.new(
          stock_location: stock_location,
          shipping_rates: shipping_rates,
          inventory_units: contents.map(&:inventory_unit)
        )
      end

      private

      def variant_ids
        contents.map { |item| item.inventory_unit.store_variant.variant_id }.compact.uniq
      end
    end
  end
end
