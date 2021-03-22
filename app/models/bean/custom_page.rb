# frozen_string_literal: true

module Bean
  class CustomPage < ApplicationRecord
    # constants
    BASE_PATH = "pages/extra/custom-page"

    # concerns
    include PageLinksConcern
    include Bean::DraftResourceConcern

    # attr related macros
    delegate :id, to: :formal_custom_page, prefix: true

    # association macros
    belongs_to :target, polymorphic: true

    # validation macros
    validates_presence_of :slug, :title
    validate :check_slug

    # callbacks

    # other macros
    set_draft_version_handling_methods resource_name: "custom_page"

    # scopes

    # class methods

    # instance methods
    def mini_program_path_name
      title
    end

    def mini_program_path
      "#{BASE_PATH}?slug=#{slug}&title=#{title}"
    end

    private

    def check_slug
      if slug
        if slug =~ %r([\s+/?%#&=\p{Han}])
          errors.add(:slug, "英文名不可包括中文、空格或 ‘+ / ? % # & =’ 中的任意字符")
        end

        # TODO 遇到未知问题，临时去掉，替换新自定义页面后再调试
        # errors.add(:slug, "已经被使用") if self.class.where(slug: slug, target_type: target_type, target_id: target_id).where.not(id: id, draft_custom_page_id: nil).first
      end
    end
  end
end
