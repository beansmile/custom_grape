# frozen_string_literal: true

module Bean
  class AfterSaleItem < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :after_sale, class_name: "Bean::AfterSale"
    belongs_to :line_item, class_name: "Bean::LineItem"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
