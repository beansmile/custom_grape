# frozen_string_literal: true

module Bean
  class StoreStockLocation < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :store, class_name: "Bean::Store"
    belongs_to :stock_location, class_name: "Bean::StockLocation"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
  end
end
