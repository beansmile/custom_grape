# frozen_string_literal: true

module AppAPI::Helpers
  module ShareIncludeHelper
    # 以下以AppAPI::Entities::Post为例
    # 需要增加includes额外关联时
    # def post_additional_includes
    #   []
    # end
    #
    # 需要移除includes部分关联时
    # def post_except_includes
    #   []
    # end
  end
end
