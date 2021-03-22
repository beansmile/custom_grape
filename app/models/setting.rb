# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  include SettingActiveStorageConcern

  # attachment_fields :default_share_cover

  cache_prefix { "v1" }

  # Define your fields
  field :customer_service_phone, type: :string
  field :customer_service_email, type: :string, default: "support@magicbeanmall.com"
end
