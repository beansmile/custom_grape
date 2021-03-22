# frozen_string_literal: true

module Grape
  class Endpoint
    include Rails.application.routes.url_helpers
  end

  class Grape::API::Instance
    include Grape::Kaminari
    extend Grape::Attack::Extension
  end

  class API
    DEFAULT_HTTP_CODES = [
      [200, "数据请求成功"],
      [400, "数据请求错误"],
      [401, "未授权访问"],
      [403, "禁止访问"],
      [404, "资源不存在"],
      [500, "服务器错误"]
    ].freeze
  end
end
