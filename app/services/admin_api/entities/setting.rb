# frozen_string_literal: true
module AdminAPI::Entities
  class SimpleSetting < Grape::Entity
    expose :customer_service_phone
    expose :customer_service_email
  end

  class Setting < SimpleSetting
  end

  class SettingDetail < Setting
  end
end
