# frozen_string_literal: true

module Bean
  class Country < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    has_many :addresses, foreign_key: :country_code, primary_key: :code, class_name: "Bean::Address", dependent: :restrict_with_error
    has_many :provinces, class_name: "Bean::Province", dependent: :destroy

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
