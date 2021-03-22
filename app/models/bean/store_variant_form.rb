# frozen_string_literal: true

module Bean
  class StoreVariantForm
    # constants

    # concerns
    include ActiveModel::Model
    include Virtus.model

    # attr related macros
    attribute :store_variant_id, Integer
    attribute :count_on_hand, Integer

    # association macros

    # validation macros
    validates :count_on_hand, numericality: { greater_than_or_equal_to: 0 }
    validates_associated :store_variant

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def store_variant
      @store_variant ||= StoreVariant.find_by(id: store_variant_id)
    end

    def store_variant_attributes=(data)
      store_variant.assign_attributes(data)

      @store_variant = store_variant
    end

    def save
      ActiveRecord::Base.transaction do
        store_variant.save

        # 当前model只处理一个店只有关联一个stock_location的场景
        StockLocationItem.find_by(stock_location_id: store_variant.store.stock_locations.first, variant_id: store_variant.variant_id).update(count_on_hand: count_on_hand)
      end
    end
  end
end
