# frozen_string_literal: true

module Bean
  class ProductTaxon < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :product, class_name: "Bean::Product"
    belongs_to :taxon, class_name: "Bean::Taxon"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
