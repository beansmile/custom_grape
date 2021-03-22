# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleCalculator < ::Entities::Model
    expose :preferences
  end

  class Calculator < SimpleCalculator
  end

  class CalculatorDetail < Calculator
  end
end
