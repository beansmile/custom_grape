# frozen_string_literal: true

module Bean
  class City < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :province, class_name: "Bean::Province"

    has_many :addresses, foreign_key: :city_code, primary_key: :code, class_name: "Bean::Address", dependent: :restrict_with_error
    has_many :districts, class_name: "Bean::District", dependent: :destroy

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
