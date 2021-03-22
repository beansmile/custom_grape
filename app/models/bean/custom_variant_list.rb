# frozen_string_literal: true

module Bean
  class CustomVariantList < ApplicationRecord
    # constants
    # TODO: 修改路径
    BASE_PATH = "pages/custom-variant-list/custom-variant-list"

    # concerns

    # attr related macros
    enum kind: {
      custom: 0,
      success_pay: 1
    }

    # association macros
    belongs_to :target, polymorphic: true

    # validation macros
    validates_presence_of :title
    validates_uniqueness_of :title, scope: [:target_type, :target_id]

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def store_variants
      Bean::StoreVariant.includes(variant: :product).where(id: store_variant_ids)
    end

    def mini_program_path_name
      title
    end

    def mini_program_path
      "#{BASE_PATH}?id=#{id}&title=#{title}"
    end
  end
end
