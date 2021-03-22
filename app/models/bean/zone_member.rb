# frozen_string_literal: true

module Bean
  class ZoneMember < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :zone, class_name: "Bean::Zone"
    belongs_to :zoneable, polymorphic: true

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
