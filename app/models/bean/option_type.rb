# frozen_string_literal: true

module Bean
  class OptionType < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :merchant, class_name: "Bean::Merchant"

    has_many :option_values, class_name: "Bean::OptionValue", dependent: :destroy
    accepts_nested_attributes_for :option_values, allow_destroy: true
    has_many :product_option_types, class_name: "Bean::ProductOptionType", dependent: :restrict_with_error

    # validation macros
    validates :name, presence: true, uniqueness: { scope: :merchant_id }

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
