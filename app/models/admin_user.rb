# frozen_string_literal: true

class AdminUser < ApplicationRecord
  # constants

  # concerns
  include UserConcern

  # attr related macros
  has_secure_password

  # association macros
  has_and_belongs_to_many :roles
  has_many :admin_users_roles, -> { order("admin_users_roles.application_id ASC NULLS FIRST, admin_users_roles.id ASC") }, inverse_of: :admin_user

  accepts_nested_attributes_for :admin_users_roles, allow_destroy: true

  # validation macros
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email?
  validates :phone, phony_plausible: true, if: :phone?
  validates :password, length: { minimum: 8, allow_blank: true }
  validates :password, presence: true, on: :create

  # callbacks

  # other macros
  phony_normalize :phone

  # scopes

  # class methods
  def self.find_by_email(email)
    where("lower(email) = ?", email.downcase).first
  end

  # instance methods

  def computed_permissions
    roles.map(&:computed_permissions).reduce(RoleCore::ComputedPermissions.new, &:concat)
  end

  def role_names
    roles.map(&:name)
  end

  def send_reset_password_instructions
    token = set_reset_password_token
    send_reset_password_instructions_notification(token)
    token
  end

  def self.digest_token(token)
    OpenSSL::HMAC.hexdigest("SHA256", token_key, token)
  end

  def clear_reset_password_token
    update(reset_password_token: nil, reset_password_sent_at: nil)
  end

  protected
  def set_reset_password_token
    raw, enc = AdminUser.generate_token
    update(reset_password_token: enc, reset_password_sent_at: Time.current)
    raw
  end

  def send_reset_password_instructions_notification(token)
    AdminUserMailer.reset_password(email, token).deliver_later
  end

  private
  class << self
    def friendly_token(length = 20)
      # To calculate real characters, we must perform this operation.
      # See SecureRandom.urlsafe_base64
      rlength = (length * 3) / 4
      SecureRandom.urlsafe_base64(rlength).tr("lIO0", "sxyz")
    end

    def generate_token
      loop do
        raw = friendly_token
        enc = OpenSSL::HMAC.hexdigest("SHA256", token_key, raw)
        break [raw, enc] unless AdminUser.find_by(reset_password_token: enc)
      end
    end

    def token_key
      Digest::MD5.digest("reset_password_token")
    end
  end
end
