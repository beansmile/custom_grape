# frozen_string_literal: true

module Bean
  class Application < ApplicationRecord
    # constants
    EXPERIENCE_DAYS = 10

    # concerns
    include ApplicationAccessTokenConcern

    # attr related macros
    delegate :client, to: :wechat_application, prefix: true, allow_nil: true
    delegate :id, to: :store_admin_users_role, prefix: true

    # association macros
    belongs_to :creator, class_name: "AdminUser", optional: true
    belongs_to :wechat_application, class_name: "WechatThirdPartyPlatform::Application", optional: true

    has_one :app_config, class_name: "Bean::AppConfig", dependent: :destroy
    has_one :register, class_name: "WechatThirdPartyPlatform::Register", foreign_key: :application_id
    # TODO SAAS版一个应用只有一个店铺管理员
    has_one :store_admin_users_role, -> { joins(:role).where(roles: { kind: "store" }) }, class_name: "AdminUsersRole"
    has_many :merchants, class_name: "Bean::Merchant", dependent: :restrict_with_error
    has_many :payment_methods, class_name: "Bean::PaymentMethod", dependent: :restrict_with_error
    has_many :express_services, class_name: "Bean::ExpressService", dependent: :restrict_with_error
    has_many :stores, class_name: "Bean::Store", through: :merchants, dependent: :restrict_with_error
    has_many :custom_pages, class_name: "Bean::CustomPage", as: :target, dependent: :destroy
    has_many :pages, dependent: :destroy
    has_many :taxonomies, class_name: "Bean::Taxonomy", through: :merchants
    has_many :users, dependent: :destroy
    has_many :custom_variant_lists, class_name: "Bean::CustomVariantList", as: :target, dependent: :destroy

    # validation macros
    validates :name, presence: true
    validates :mobile, phony_plausible: { allow_blank: true }

    # callbacks
    before_validation :drop_hidden_filed
    before_create :set_expired_at
    after_create :create_relevant_data

    # other macros
    has_one_attached :logo
    has_one_attached :share_image
    phony_normalize :mobile

    # scopes
    scope :recent_day, -> (day) { where(arel_table[:created_at].gteq(day.days.ago.beginning_of_day)) }

    # class methods

    # instance methods
    def update_expired_at(attributes)
      update(expired_at: attributes[:expired_at])
    end

    def expired?
      expired_at && Time.current > expired_at
    end

    def authorize_state
      # 已经授权或者创建应用微信已成功
      if wechat_application
        "authorized"
      else
        # 已经提交快速审核
        if register
          "register_#{register.state}"
        else
          "pending"
        end
      end
    end

    def associated_application_ids
      [id]
    end

    def associated_merchant_ids
      merchants.ids
    end

    def associated_store_ids
      stores.ids
    end

    def wechat_mini_program_client
      @wechat_mini_program_client ||= BsWechatMiniProgram::Client.new(appid, secret)
    end

    def kuaidi100_service
      express_services.where(type: 'Bean::ExpressService::Kuaidi100').last
    end

    def current_express_service
      express_services.where(is_active: true).last
    end

    def kuaidi100_service_client
      @express_servide_client ||= kuaidi100_service&.client
    end

    def hidden_filed_show
      "***********"
    end

    # 当前端传过来带*号的属性，则忽略该属性更新
    def drop_hidden_filed
      if changes.keys.include?("secret") && secret.include?("**")
        self.clear_attribute_changes(["secret"])
      end
    end

    private

    def create_relevant_data
      create_app_config

      custom_page = custom_pages.new(slug: "home", title: "首页", default: true)
      custom_page.create_with_formal_custom_page

      pages.create!(slug: "about_us", title: "关于我们", type: "PresetPage", content: "关于我们")

      custom_variant_lists.create!(title: "推荐商品（支付成功页面）", kind: "success_pay")

      merchant = merchants.create!(name: name)
      store = Store.create!(name: name, merchant: merchant)
      store.stock_locations << StockLocation.create!(name: name)

      # 先默认预置一个空的 Kuaidi100 配置
      Bean::ExpressService::Kuaidi100.create(name: '快递100服务', is_active: true, application_id: id)

      creator.admin_users_roles.create!(store: store, role: Role.store_kind.first)
    end

    def set_expired_at
      self.expired_at = EXPERIENCE_DAYS.days.since.end_of_day
    end
  end
end
