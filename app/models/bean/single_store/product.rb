# frozen_string_literal: true

module Bean::SingleStore
  class Product
    # constants

    # concerns
    include ActiveModel::Model
    include Virtus.model

    # attr related macros
    attr_accessor :product, :images, :detail_images, :share_image, :poster_image

    [
      [:name, String],
      [:description, String],
      [:available_on, DateTime],
      [:discontinue_on, DateTime],
      [:taxon_ids, Array[Integer]],
      [:shipping_template_id, Integer],
      [:merchant_id, Integer],
      [:option_type_ids, Array[Integer]],
      [:share_title, String],
    ].each do |array|
      column_name, column_type = array

      attribute column_name, column_type, default: lambda { |object, _| object.product.send(column_name) }
    end

    delegate :id,
      :created_at,
      :updated_at,
      :shipping_template,
      :taxons,
      :sales_volume,
      :main_image,
      to: :product

    # association macros
    validates :name, presence: true
    validates :taxon_ids, length: { minimum: 1, too_short: "最少需要关联一个"  }
    validates :option_type_ids, length: { minimum: 1, too_short: "最少需要关联一个"  }
    validates :images, length: { minimum: 1, too_short: "最少需要一张" }
    validates :detail_images, length: { minimum: 1, too_short: "最少需要一张" }

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def share_image_attachment
      @share_image_attachment ||= product.share_image
    end

    def poster_image_attachment
      @poster_image_attachment ||= product.poster_image
    end

    def image_attachments
      @image_attachments ||= product.images
    end

    def detail_image_attachments
      @detail_image_attachments ||= product.detail_images
    end

    def merchant
      @merchant ||= Bean::Merchant.find_by(id: merchant_id)
    end

    def store
      @store ||= merchant.stores.first
    end

    def variants
      @variants ||= product.variants.map do |variant|
        Variant.new(variant: variant, product: self)
      end
    end

    def variants_attributes=(data)
      @variants ||= data.map do |attrs|
        variant = Variant.new(variant: Bean::Variant.find_or_initialize_by(id: attrs[:id]), product: self)
        variant.assign_attributes(attrs)

        variant
      end
    end

    def save
      return false unless valid?

      invalid_variants = variants.select { |variant| !variant.valid? }

      if invalid_variants.any?
        invalid_variants.map { |variant| variant.errors.full_messages }.flatten.uniq.each do |error_message|
          errors.add(:base, error_message)
        end

        return false
      end

      begin
        ActiveRecord::Base.transaction do
          [
            :name,
            :description,
            :available_on,
            :discontinue_on,
            :taxon_ids,
            :shipping_template_id,
            :merchant_id,
            :option_type_ids,
            :images,
            :detail_images,
            :share_title,
            :share_image,
            :poster_image,
          ].each do |attr|
            product.send("#{attr}=", send(attr))
          end

          product.save!
          variants.each(&:save!)

          store_variants = Bean::StoreVariant.where(variant_id: product.variant_ids, store: store.id).order("cost_price, id")
          store_variants.each { |store_variant| store_variant.update(is_master: false) }

          store_variant = store_variants.detect { |store_variant| store_variant.is_active? }

          store_variant.update(is_master: true) if store_variant
        end
      rescue ActiveRecord::RecordInvalid => error
        errors.add(:base, error.message)

        return false
      end

      true
    end

    def update(attrs)
      assign_attributes(attrs)

      save
    end
  end
end
