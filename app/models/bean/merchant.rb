# frozen_string_literal: true

module Bean
  class Merchant < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :application, class_name: "Bean::Application"
    has_many :stores, class_name: "Bean::Store", dependent: :restrict_with_error
    has_many :products, class_name: "Bean::Product", dependent: :restrict_with_error
    has_many :taxonomies, class_name: "Bean::Taxonomy", dependent: :destroy
    has_many :taxons, class_name: "Bean::Taxon", through: :taxonomies

    # validation macros

    # callbacks
    after_create :create_taxonomy

    # other macros
    delegate :appid, to: :application

    # scopes
    scope :active, -> { where(is_active: true) }

    # class methods

    # instance methods
    def associated_application_ids
      [application_id]
    end

    def associated_merchant_ids
      [id]
    end

    def associated_store_ids
      stores.ids
    end

    private

    def create_taxonomy
      taxonomies.create(name: "分类", taxonomy_type: "category")
    end
  end
end
