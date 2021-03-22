# frozen_string_literal: true

module Bean
  class Calculator < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :calculable, polymorphic: true

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def compute(computable)
      # Bean::LineItem -> :compute_line_item
      computable_name = computable.class.name.demodulize.underscore
      method = "compute_#{computable_name}".to_sym
      calculator_class = self.class
      if respond_to?(method)
        send(method, computable)
      else
        raise NotImplementedError, "Please implement '#{method}(#{computable_name})' in your calculator: #{calculator_class.name}"
      end
    end
  end
end
