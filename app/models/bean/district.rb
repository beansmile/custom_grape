# frozen_string_literal: true

module Bean
  class District < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :city, class_name: "Bean::City"

    has_many :addresses, foreign_key: :district_code, primary_key: :code, class_name: "Bean::Address", dependent: :restrict_with_error

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
