# frozen_string_literal: true

module Bean
  class Province < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :country, class_name: "Bean::Country"

    has_many :addresses, foreign_key: :province_code, primary_key: :code, class_name: "Bean::Address", dependent: :restrict_with_error
    has_many :cities, class_name: "Bean::City", dependent: :destroy

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
