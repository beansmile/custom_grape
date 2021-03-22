# frozen_string_literal: true

module Bean
  class Taxonomy < ApplicationRecord
    # constants

    # concerns

    # attr related macros
    enum taxonomy_type: { category: 0 }

    # association macros
    belongs_to :merchant, class_name: "Bean::Merchant"
    has_many :taxons, class_name: "Bean::Taxon", dependent: :destroy

    # validation macros

    # callbacks

    # other macros
    ransacker :taxonomy_type, formatter: proc { |value| taxonomy_types[value] }

    # scopes

    # class methods

    # instance methods
  end
end
