# frozen_string_literal: true

module Bean
  module Calculator::Shipping
    class Weight < ShippingCalculator
      # constants

      # concerns

      # attr related macros

      # association macros

      # validation macros
      validates :first_weight, numericality: { greater_than: 0 }
      validates :first_weight_price, numericality: { greater_than_or_equal_to: 0 }
      validates :continued_weight, numericality: { greater_than: 0 }
      validates :continued_weight_price, numericality: { greater_than_or_equal_to: 0 }

      # callbacks

      # other macros

      # scopes

      # class methods

      # instance methods
      def compute_package(package)
        amount = first_weight_price
        amount += ((package.weight - first_weight) / continued_weight).ceil * continued_weight_price if package.weight > first_weight

        amount
      end

      [
        "first_weight",
        "first_weight_price",
        "continued_weight",
        "continued_weight_price"
      ].each do |attr|
        define_method attr do
          preferences[attr].to_d
        end
      end
    end
  end
end
