# frozen_string_literal: true

class AdminAPI::V1 < API
  prefix "admin_api"
  version "v1"

  [
    :AdminUsersRole,
    :AdminUser,
    :Role,
    :User,
    :StaticPage,
    :PresetPage,
    :Banner,
    :Page
  ].each do |model_name|
    path = "./app/services/admin_api/entities/#{model_name.to_s.underscore}.rb"

    ::AdminAPI::Entities.autoload "Simple#{model_name}".to_sym, path
    ::AdminAPI::Entities.autoload "#{model_name}Detail".to_sym, path
  end

  ::AdminAPI::Entities.autoload :Mine, "./app/services/admin_api/entities/admin_user.rb"

  [
    # 以下代码为generator插入代码的标记，请勿修改或删除
    # Entity autoload
    :CustomVariantList,
    :LineItem,
    :Country,
    :Province,
    :City,
    :District,
    :Address,
    :Order,
    :Variant,
    :StoreVariant,
    :Taxon,
    :Taxonomy,
    :ShippingTemplate,
    :Product,
    :OptionValue,
    :OptionType,
    :CustomPage,
    :Store,
    :Merchant,
    :Application,
    :PaymentMethod,
    :Shipment,
    :StockLocation,
    :InventoryUnit,
    :ExpressService,
  ].each do |model_name|
    path = "./app/services/admin_api/entities/bean/#{model_name.to_s.underscore}.rb"

    ::AdminAPI::Entities::Bean.autoload "Simple#{model_name}".to_sym, path
    ::AdminAPI::Entities::Bean.autoload "#{model_name}Detail".to_sym, path
  end

  [
    :Tag,
  ].each do |model_name|
    path = "./app/services/admin_api/entities/acts_as_taggable_on/#{model_name.to_s.underscore}.rb"

    ::AdminAPI::Entities::ActsAsTaggableOn.autoload "Simple#{model_name}".to_sym, path
    ::AdminAPI::Entities::ActsAsTaggableOn.autoload "#{model_name}Detail".to_sym, path
  end

  [
    :Blob,
  ].each do |model_name|
    path = "./app/services/admin_api/entities/active_storage/#{model_name.to_s.underscore}.rb"

    ::AdminAPI::Entities::ActiveStorage.autoload "Simple#{model_name}".to_sym, path
    ::AdminAPI::Entities::ActiveStorage.autoload "#{model_name}Detail".to_sym, path
  end

  [
    :Product,
    :Variant,
  ].each do |model_name|
    path = "./app/services/admin_api/entities/bean/single_store/#{model_name.to_s.underscore}.rb"

    ::AdminAPI::Entities::Bean::SingleStore.autoload "Simple#{model_name}".to_sym, path
    ::AdminAPI::Entities::Bean::SingleStore.autoload "#{model_name}Detail".to_sym, path
  end


  helpers AdminAPI::Helpers::ResourceHelper
  helpers AdminAPI::Helpers::AuthenticationHelper
  helpers AdminAPI::Helpers::ShareIncludeHelper
  helpers AdminAPI::Helpers::ExportXlsxHelper

  mount ::AdminAPI::V1::Sessions
  mount ::AdminAPI::V1::Passwords
  mount ::AdminAPI::V1::VerificationCodes
  mount ::AdminAPI::V1::Registrations
  mount ::AdminAPI::V1::Captcha

  before do
    if require_authentication?
      authenticate!
      authenticate_admin_users_role!
    end
  end

  mount ::AdminAPI::V1::Mine
  mount ::AdminAPI::V1::AdminUsers
  mount ::AdminAPI::V1::AdminUsersRoles
  mount ::AdminAPI::V1::Roles
  mount ::AdminAPI::V1::Banners
  mount ::AdminAPI::V1::PresetPages
  mount ::AdminAPI::V1::StaticPages
  mount ::AdminAPI::V1::Users
  mount ::AdminAPI::V1::Dashboard
  mount ::AdminAPI::V1::ActiveStorage
  mount ::AdminAPI::V1::Bean::Applications
  mount ::AdminAPI::V1::Bean::Merchants
  mount ::AdminAPI::V1::Bean::Stores
  mount ::AdminAPI::V1::Bean::CustomPages
  mount ::AdminAPI::V1::Bean::OptionTypes
  mount ::AdminAPI::V1::Bean::OptionValues
  mount ::AdminAPI::V1::Bean::Products
  mount ::AdminAPI::V1::Bean::ShippingTemplates
  mount ::AdminAPI::V1::Bean::StoreVariants
  mount ::AdminAPI::V1::Bean::Taxonomies
  mount ::AdminAPI::V1::Bean::Taxons
  mount ::AdminAPI::V1::Bean::PaymentMethods
  mount ::AdminAPI::V1::Bean::Orders
  mount ::AdminAPI::V1::Bean::BatchStoreVariantForms
  mount ::AdminAPI::V1::Pages
  mount ::AdminAPI::V1::Bean::Shipments
  mount ::AdminAPI::V1::Bean::SingleStore::Products
  mount ::AdminAPI::V1::Bean::CustomVariantLists
  mount ::AdminAPI::V1::Bean::PageLinks
  mount ::AdminAPI::V1::Bean::ExpressServices
  mount ::AdminAPI::V1::Settings
  mount ::AdminAPI::V1::ActiveStorage::Blobs
  mount ::AdminAPI::V1::ActsAsTaggableOn::Tags

  mount ::WechatThirdPartyPlatform::GrapeAPI::Base
  mount ::WechatThirdPartyPlatform::GrapeAPI::DraftTemplates
  mount ::WechatThirdPartyPlatform::GrapeAPI::Templates
  mount ::WechatThirdPartyPlatform::GrapeAPI::Registers
  mount ::WechatThirdPartyPlatform::GrapeAPI::Applications
  mount ::WechatThirdPartyPlatform::GrapeAPI::Testers
  mount ::WechatThirdPartyPlatform::GrapeAPI::WechatCategories
  mount ::WechatThirdPartyPlatform::GrapeAPI::DataAnalysis
  mount ::WechatThirdPartyPlatform::GrapeAPI::Utils
  mount ::WechatThirdPartyPlatform::GrapeAPI::TemplateSettings

  add_swagger_documentation
end
