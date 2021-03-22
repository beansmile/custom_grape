# frozen_string_literal: true

module Bean
  class ProductOptionType < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :product, class_name: "Bean::Product"
    belongs_to :option_type, class_name: "Bean::OptionType"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
