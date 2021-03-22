# frozen_string_literal: true

module Bean
  class ShareSetting < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :target, polymorphic: true
    belongs_to :store

    has_one_attached :share_background_cover
    has_one_attached :share_cover

    # validation macros
    before_validation :set_store_id

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    private

    def set_store_id
      self.store_id = target.store_id if target.respond_to?(:store_id)
    end
  end
end
