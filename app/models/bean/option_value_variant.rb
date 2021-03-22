# frozen_string_literal: true

module Bean
  class OptionValueVariant < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :option_value, class_name: "Bean::OptionValue"
    belongs_to :variant, class_name: "Bean::Variant"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
