# frozen_string_literal: true

module Bean::SingleStore
  class Variant
    # constants

    # concerns
    include ActiveModel::Model
    include Virtus.model

    # attr related macros
    attr_accessor :variant, :product

    [
      [:id, Integer],
      [:sku, String],
      [:weight, Decimal],
      [:option_value_ids, Array[Integer]],
    ].each do |array|
      column_name, column_type = array

      attribute column_name, column_type, default: lambda { |object, _| object.variant.send(column_name) }
    end

    [
      [:cost_price, Decimal],
      [:origin_price, Decimal],
      [:count_on_hand, Integer],
      [:is_active, Boolean],
    ].each do |array|
      column_name, column_type = array

      attribute column_name, column_type, default: lambda { |object, _| object.store_variant.send(column_name) }
    end

    delegate :id,
      :created_at,
      :updated_at,
      :option_values,
      :sales_volume,
      to: :variant

    delegate :store, to: :product

    # association macros

    # validation macros
    validates :sku, presence: true
    validates :weight, numericality: { greater_than_or_equal_to: 0, allow_blank: true }, presence: true
    validates :cost_price, numericality: { greater_than: 0, allow_blank: true }, presence: true
    validates :origin_price, numericality: { greater_than_or_equal_to: 0, allow_blank: true }, presence: true
    validates :count_on_hand, numericality: { greater_than_or_equal_to: 0, allow_blank: true }, presence: true

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def store_variant
      @store_variant ||= variant.store_variants.find_or_initialize_by(store_id: store.id)
    end

    def save!
      variant.product = product.product

      [
        :sku,
        :weight,
        :option_value_ids,
      ].each do |attr|
        variant.send("#{attr}=", send(attr))
      end

      [
        :cost_price,
        :origin_price,
        :is_active
      ].each do |attr|
        store_variant.send("#{attr}=", send(attr))
      end

      # TOFIX 如果variant为新纪录时，会同时保存store_variant，如果不是则不会
      if variant.new_record?
        variant.save!
      else
        store_variant.save!
        variant.save!
      end

      stock_location = store.stock_locations.first
      stock_location_item = Bean::StockLocationItem.find_or_initialize_by(stock_location_id: stock_location.id, variant_id: variant.id)
      stock_location_item.update(count_on_hand: count_on_hand)
    end
  end
end
