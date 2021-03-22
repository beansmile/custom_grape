# frozen_string_literal: true

class Banner < ApplicationRecord
  # constants

  # concerns

  # attr related macros
  enum page_position: {
  }
  enum kind: {
    web_link: 0,
    image: 1,
    mp_link: 2
  }, _suffix: true

  # association macros
  belongs_to :application, class_name: "Bean::Application"

  # validation macros

  validates :page_position, presence: true
  # validates :alt, presence: true
  validates :image, attach_presence: true
  validate :check_target_url, unless: -> { image_kind? }
  validates :kind, presence: true

  # callbacks
  before_save :reset_link, if: :image_kind?

  # other macros
  ransacker :page_position, formatter: proc { |val| page_positions[val] }
  ransacker :kind, formatter: proc { |v| kinds[v] }

  has_one_attached :image

  # scopes

  # class methods

  # instance methods
  private

  def reset_link
    target.delete "url"
  end

  def check_target_url
    return if image_kind?

    errors.add(:target, I18n.t("errors.messages.blank")) if target["url"].blank?
  end
end
