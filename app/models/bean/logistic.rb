# frozen_string_literal: true

module Bean
  class Logistic < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :order, class_name: "Bean::Order"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
