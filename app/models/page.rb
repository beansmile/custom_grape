# frozen_string_literal: true

class Page < ApplicationRecord
  # constants
  BASE_PATH = "pages/extra/webview"

  # concerns
  extend FriendlyId
  include RichEditorContentOptimizeConcern

  # attr related macros
  enum status: { draft: 1, published: 2 }
  friendly_id :slug

  # association macros
  belongs_to :application, class_name: "Bean::Application"

  # validation macros
  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: { scope: :application_id }

  # callbacks

  # other macros
  has_one_attached :wxacode

  optimize_rich_editor_content :content

  # scopes

  # class methods

  # instance methods
  def publish
    update(status: :published)
  end

  def save_as_draft
    update(status: :draft)
  end

  def mini_program_path_name
    title
  end

  def mini_program_path
    "#{BASE_PATH}?slug=#{slug}"
  end
end
