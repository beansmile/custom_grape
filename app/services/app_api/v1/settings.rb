# frozen_string_literal: true

module AppAPI
  class AppAPI::V1::Settings < ::API
    # 配置 API
    namespace :settings, desc: "配置 API" do
      desc "获取配置", skip_authentication: true
      get do
        data = Setting.all.map do |item|
          [item.var, item.is_attachement_field? ? item.expose_attachment : item.value]
        end.to_h
        data
      end
    end
  end
end
