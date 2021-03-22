# frozen_string_literal: true

module Bean
  class Store < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :merchant, class_name: "Bean::Merchant"

    has_many :store_variants, class_name: "Bean::StoreVariant", dependent: :destroy
    has_many :variants, through: :store_variants
    has_many :admin_users_roles, dependent: :restrict_with_error
    has_many :roles, dependent: :restrict_with_error
    has_many :store_stock_locations, class_name: "Bean::StoreStockLocation", dependent: :destroy
    has_many :stock_locations, through: :store_stock_locations
    has_many :orders, dependent: :restrict_with_error
    has_many :after_sales, dependent: :restrict_with_error

    # validation macros

    # callbacks

    # other macros
    delegate :application_id, :appid, to: :merchant

    # scopes

    # class methods

    # instance methods
    def products
      @products ||= Bean::Product.where(id: variants.select(:product_id))
    end

    def active?
      not_discontinue_on
    end

    def not_discontinue_on
      discontinue_on.nil? || discontinue_on > Time.current
    end

    def associated_application_ids
      [application_id]
    end

    def associated_merchant_ids
      [merchant_id]
    end

    def associated_store_ids
      [id]
    end
  end
end
