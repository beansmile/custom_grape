# frozen_string_literal: true

module Bean
  class Adjustment < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :order, class_name: "Bean::Order"
    belongs_to :adjustable, polymorphic: true
    belongs_to :source, polymorphic: true

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
