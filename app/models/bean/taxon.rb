# frozen_string_literal: true

module Bean
  class Taxon < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :parent, class_name: "Bean::Taxon", optional: :true
    belongs_to :taxonomy, class_name: "Bean::Taxonomy"

    has_many :children, class_name: "Bean::Taxon", foreign_key: "parent_id", dependent: :restrict_with_error
    has_many :product_taxons, class_name: "Bean::ProductTaxon", dependent: :restrict_with_error

    has_one_attached :icon

    # validation macros
    validate :check_taxonomy_and_parent, :check_icon_exists

    # callbacks

    # other macros

    # scopes
    scope :top, -> { where(parent_id: nil) } # `parent` 类方法已被 Rails 占用，所以用 `top` 表示一级分类
    scope :children, -> { where.not(parent_id: nil) }

    # class methods

    # instance methods

    private

    def check_taxonomy_and_parent
      errors.add(:base, "分类与一级分类单元不匹配") if parent && parent.taxonomy_id != taxonomy_id
    end

    def check_icon_exists
      errors.add(:base, "二级分类图标必填") if parent_id && !icon.attached?
    end
  end
end
