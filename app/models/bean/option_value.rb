# frozen_string_literal: true

module Bean
  class OptionValue < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :option_type, class_name: "Bean::OptionType"

    has_many :option_value_variants, class_name: "Bean::OptionValueVariant", dependent: :restrict_with_error

    # validation macros
    validates :name, presence: true, uniqueness: { scope: :option_type_id }

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
