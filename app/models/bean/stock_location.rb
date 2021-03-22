# frozen_string_literal: true

module Bean
  class StockLocation < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    has_many :stock_location_items, class_name: "Bean::StockLocationItem", dependent: :restrict_with_error
    has_many :store_stock_locations, class_name: "Bean::StoreStockLocation", dependent: :restrict_with_error

    # validation macros

    # callbacks

    # other macros

    # scopes
    scope :active, -> { where(is_active: true) }

    # class methods

    # instance methods
    def stocks?(variant)
      stock_location_items.exists?(variant: variant)
    end
  end
end
