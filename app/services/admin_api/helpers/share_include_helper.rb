# frozen_string_literal: true

module AdminAPI::Helpers
  module ShareIncludeHelper
    # 以下以AdminAPI::Entities::Post为例
    # 需要增加includes额外关联时
    # def post_additional_includes
    #   []
    # end
    #
    # 需要移除includes部分关联时
    # def post_except_includes
    #   []
    # end

    def user_additional_includes
      [:profile]
    end
  end
end
