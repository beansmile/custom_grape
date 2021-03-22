# frozen_string_literal: true
class AdminAPI::V1::Settings < API

  namespace :settings, desc: "系统配置" do
    params do
      optional :customer_service_phone, type: String
      optional :customer_service_email, type: String
    end
    put do
      authorize! :update, "Setting"
      resource_params.keys.each do |key|
        Setting.send("#{key}=", resource_params[key].strip) unless resource_params[key].nil?
      end
      present ::Setting, with: ::AdminAPI::Entities::Setting
    end

    get do
      authorize! :read, "Setting"
      present ::Setting, with: ::AdminAPI::Entities::Setting
    end
  end
end
