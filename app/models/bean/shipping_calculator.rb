# frozen_string_literal: true

module Bean
  class ShippingCalculator < Calculator
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
    def compute_package(_package)
      raise NotImplementedError, "Please implement 'compute_package(package)' in your calculator: #{self.class.name}"
    end

    def available?(_package)
      true
    end
  end
end
