# frozen_string_literal: true

class User < ApplicationRecord
  # constants
  TRACKING_CODE_LENGTH = 8

  # concerns
  include UserConcern

  # attr related macros

  # association macros
  with_options dependent: :restrict_with_error do
    # has_many :posts
    has_many :oauth_identities
    has_one :profile
    has_many :orders, class_name: "Bean::Order"
  end
  belongs_to :application, class_name: "Bean::Application"

  has_one :shopping_cart, class_name: "Bean::ShoppingCart", dependent: :destroy
  has_many :addresses, class_name: "Bean::Address", dependent: :destroy

  # validation macros
  validates :tracking_code, presence: true, uniqueness: true

  # callbacks
  before_validation :generate_tracking_code, on: :create
  after_save :create_cart

  # other macros
  scope :recent_day, -> (day) { where(arel_table[:created_at].gteq(day.days.ago.beginning_of_day)) }

  delegate :name, :email, :phone, :gender, to: :profile, prefix: true, allow_nil: true
  delegate :id, to: :shopping_cart, prefix: true, allow_nil: true

  has_one_attached :avatar

  # scopes
  scope :today, -> { where(arel_table[:created_at].gteq(Time.current.midnight)) }

  # class methods

  # instance methods

  def wechat_mp_openid
    @wechat_mp_openid ||= oauth_identities.find_by(provider: OauthIdentity::PROVIDERS[:wechat_mini_program])&.primary_uid
  end

  def wechat_mp_session_key
    @wechat_mp_session_key ||= oauth_identities.find_by(provider: OauthIdentity::PROVIDERS[:wechat_mini_program])&.credentials&.dig("session_key")
  end

  def sns_authorized
    !!sns_authorized_at
  end

  def init_orders_count
    orders.init.count
  end

  def shipment_state_pending_orders_count
    orders.joins(:shipments).where(bean_shipments: { state: Bean::Shipment.states["pending"] } ).distinct.count
  end

  def shipped_orders_count
    orders.joins(:shipments).where(bean_shipments: { state: Bean::Shipment.states["shipped"] } ).distinct.count
  end

  private

  def generate_tracking_code
    loop do
      self.tracking_code = GlobalConstant::ALPHABET_ARRAY.sample(TRACKING_CODE_LENGTH).join
      break unless self.class.exists?(tracking_code: tracking_code)
    end
  end

  def create_cart
    # 静默授权不创建购物车，用户授权后才创建
    create_shopping_cart if sns_authorized_at_previously_changed? && sns_authorized_at_previous_change[0].nil? && shopping_cart.nil?
  end
end
