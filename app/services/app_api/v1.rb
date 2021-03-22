# frozen_string_literal: true

class AppAPI::V1 < API
  prefix "app_api"
  version "v1"

  [
    # 以下代码为generator插入代码的标记，请勿修改或删除
    # Entity autoload
    :PaymentMethod,
    :Application,
    :CustomPage,
    :Banner,
    :Page,
    :User,
  ].each do |model_name|
    path = "./app/services/app_api/entities/#{model_name.to_s.underscore}.rb"

    ::AppAPI::Entities.autoload "Simple#{model_name}".to_sym, path
    ::AppAPI::Entities.autoload "#{model_name}Detail".to_sym, path
  end

  [
    :CustomVariantList,
    :Product,
    :Variant,
    :StoreVariant,
    :ShoppingCartItem,
    :ShoppingCart,
    :OptionType,
    :OptionValue,
    :Taxonomy,
    :Taxon,
    :Store,
    :Address,
    :Order,
    :Country,
    :Province,
    :City,
    :District,
    :Shipment,
    :InventoryUnit,
    :ShippingRate,
    :ShoppingCartItemGroup,
    :StockLocation,
    :Application,
  ].each do |model_name|
    path = "./app/services/app_api/entities/bean/#{model_name.to_s.underscore}.rb"

    ::AppAPI::Entities::Bean.autoload "Simple#{model_name}".to_sym, path
    ::AppAPI::Entities::Bean.autoload "#{model_name}Detail".to_sym, path
  end

  ::AppAPI::Entities.autoload :Mine, "./app/services/app_api/entities/user.rb"

  helpers AppAPI::Helpers::AuthenticationHelper
  helpers AppAPI::Helpers::ResourceHelper
  helpers AppAPI::Helpers::ShareIncludeHelper

  before do
    if require_authentication?
      authenticate!
      check_application!
    end
  end

  mount ::AppAPI::V1::ActionStores
  mount ::AppAPI::V1::Auth
  mount ::AppAPI::V1::Banners
  mount ::AppAPI::V1::Mine
  mount ::AppAPI::V1::Pages
  mount ::AppAPI::V1::Settings
  mount ::AppAPI::V1::ActiveStorage
  mount ::AppAPI::V1::Bean::ShoppingCartItems
  mount ::AppAPI::V1::Bean::Taxons
  mount ::AppAPI::V1::Bean::Orders
  mount ::AppAPI::V1::Bean::Countries
  mount ::AppAPI::V1::Bean::Provinces
  mount ::AppAPI::V1::Bean::Cities
  mount ::AppAPI::V1::Bean::Districts
  mount ::AppAPI::V1::Bean::StoreVariants
  mount ::AppAPI::V1::Bean::Addresses
  mount ::AppAPI::V1::Bean::CustomPages
  mount ::AppAPI::V1::Bean::ShoppingCartItemGroups
  mount ::AppAPI::V1::Bean::Applications
  mount ::AppAPI::V1::Bean::PaymentMethods
  mount ::AppAPI::V1::Bean::CustomVariantLists

  mount ::WechatThirdPartyPlatform::GrapeAPI::Utils

  add_swagger_documentation
end
