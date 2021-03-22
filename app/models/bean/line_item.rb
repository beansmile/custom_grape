# frozen_string_literal: true

module Bean
  class LineItem < ApplicationRecord
    # constants

    # concerns
    include StoreVariantItemConcern

    # attr related macros
    delegate :store, :variant, :store_id, to: :store_variant
    delegate :active?, to: :store_variant, prefix: true

    # association macros
    belongs_to :order, class_name: "Bean::Order"
    belongs_to :store_variant, class_name: "Bean::StoreVariant"

    # validation macros

    # callbacks

    # other macros
    has_one_attached :image

    # scopes

    # class methods

    # instance methods
  end
end
