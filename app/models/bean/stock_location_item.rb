# frozen_string_literal: true

module Bean
  class StockLocationItem < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :stock_location, class_name: "Bean::StockLocation"
    belongs_to :variant, class_name: "Bean::Variant"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    # 暂不支持预订
    def backorderable?
      false
    end
  end
end
