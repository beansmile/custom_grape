# frozen_string_literal: true

module Bean
  module Stock
    class Coordinator
      attr_reader :order, :inventory_units

      def initialize(order, inventory_units = nil)
        @order = order
        @inventory_units = inventory_units || InventoryUnitBuilder.new(order).units
      end

      def shipments
        packages.map do |package|
          package.to_shipment.tap { |s| s.address = order.address }
        end
      end

      def packages
        packages = build_packages
        packages = prioritize_packages(packages)
        packages = estimate_packages(packages)
      end

      def build_packages(packages = [])
        stock_locations_with_requested_variants.each do |stock_location|
          packer = build_packer(stock_location, inventory_units)
          packages += packer.packages
        end

        packages
      end

      private

      def stock_locations_with_requested_variants
        stock_locations.joins(:stock_location_items).
          where(bean_stock_location_items: { variant_id: requested_variant_ids }).distinct
      end

      def requested_variant_ids
        inventory_units.map { |unit| unit.store_variant.variant_id }.uniq
      end

      def stock_locations
        @stock_locations ||= order.store.stock_locations.active
      end

      def prioritize_packages(packages)
        prioritizer = Prioritizer.new(packages)
        prioritizer.prioritized_packages
      end

      def estimate_packages(packages)
        estimator = Estimator.new(order)
        packages.each do |package|
          package.shipping_rates = estimator.shipping_rates(package)
        end
        packages
      end

      def build_packer(stock_location, inventory_units)
        Packer.new(stock_location, inventory_units, splitters(stock_location))
      end

      def splitters(_stock_location)
        # extension point to return custom splitters for a location
        [Bean::Stock::Splitter::ShippingTemplate]
      end
    end
  end
end
