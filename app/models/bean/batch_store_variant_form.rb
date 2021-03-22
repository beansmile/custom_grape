# frozen_string_literal: true

module Bean
  class BatchStoreVariantForm
    # constants

    # concerns
    include ActiveModel::Model
    include Virtus.model

    # attr related macros
    attribute :product_id, Integer
    attribute :store_id, Integer

    # association macros

    # validation macros
    validates_associated :store_variant_forms

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def product
      @product ||= Product.find_by(id: product_id)
    end

    def store_variant_forms
      @store_variant_forms ||= StoreVariant.where(variant_id: product.variant_ids, store: store_id).order(:id).map do |store_variant|
        StoreVariantForm.new(store_variant_id: store_variant.id, count_on_hand: store_variant.count_on_hand)
      end
    end

    def store_variant_forms_attributes=(data)
      @store_variant_forms = store_variant_forms.map do |store_variant_form|
        next unless attrs = data.detect { |hash| hash["store_variant_id"] == store_variant_form.store_variant_id }

        store_variant_form.assign_attributes(attrs)

        store_variant_form
      end
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        store_variant_forms.each(&:save)

        store_variants = StoreVariant.where(variant_id: product.variant_ids, store: store_id).order("cost_price, id")
        store_variants.each { |store_variant| store_variant.update(is_master: false) }

        store_variant = store_variants.detect { |store_variant| store_variant.is_active? }

        store_variant.update(is_master: true) if store_variant
      end

      true
    end
  end
end
