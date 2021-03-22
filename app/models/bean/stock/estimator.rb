# frozen_string_literal: true

module Bean
  module Stock
    class Estimator
      # constants

      # concerns

      # attr related macros
      attr_reader :order

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

      def shipping_rates(package)
        rates = calculate_shipping_rates(package)
        choose_default_shipping_rate(rates)
        sort_shipping_rates(rates)
      end

      private

      def choose_default_shipping_rate(shipping_rates)
        unless shipping_rates.empty?
          shipping_rates.min_by(&:cost).selected = true
        end
      end

      def sort_shipping_rates(shipping_rates)
        shipping_rates.sort_by!(&:cost)
      end

      def calculate_shipping_rates(package)
        package.shipping_templates.inject([]) do |array, shipping_template|
          shipping_template.shipping_categories.each do |shipping_category|
            selected_shipping_method = shipping_category.shipping_methods.where(is_default: false).detect do |shipping_method|
              calculator = shipping_method.calculator

              shipping_method.include?(order.address) && calculator.available?(package)
            end


            unless selected_shipping_method
              default_shipping_method = shipping_category.shipping_methods.find_by(is_default: true)

              selected_shipping_method = default_shipping_method if default_shipping_method.calculator.available?(package)
            end

            array << selected_shipping_method if selected_shipping_method
          end

          array
        end.map do |shipping_method|
          cost = shipping_method.calculator.compute(package)

          next unless cost

          shipping_method.shipping_rates.new(
            cost: cost
          )
        end.compact
      end
    end
  end
end
