# frozen_string_literal: true

class AdminUsersRole < ApplicationRecord
  # constants

  # concerns

  # attr related macros

  # association macros
  belongs_to :admin_user
  belongs_to :role
  belongs_to :application, class_name: "Bean::Application", optional: true
  belongs_to :merchant, class_name: "Bean::Merchant", optional: true
  belongs_to :store, class_name: "Bean::Store", optional: true

  # validation macros
  validate :check_platform_valid

  # callbacks
  before_save :set_platform
  after_create_commit :send_invite_email, if: :custom_kind?

  # other macros
  delegate :kind, to: :role
  delegate :store, to: :role, prefix: true
  delegate :computed_permissions, :custom_kind?, to: :role

  # scopes

  # class methods

  # instance methods

  def associated_application_ids
    (store || merchant || application)&.associated_application_ids
  end

  def associated_merchant_ids
    (store || merchant || application)&.associated_merchant_ids
  end

  def associated_store_ids
    (store || merchant || application)&.associated_store_ids
  end

  def associated_admin_user_ids
    AdminUser.ransack(admin_users_roles_application_id_eq: application_id, admin_users_roles_merchant_id_eq: merchant_id,
      admin_users_roles_store_id_eq: store_id).result.distinct.ids
  end

  def associated_wechat_application_ids
    Bean::Application.ransack(id_eq: application_id).result.pluck(:wechat_application_id)
  end

  def associated_custom_page_ids
    Bean::CustomPage.where(target_type: "Bean::Application", target_id: associated_application_ids)
      .or(Bean::CustomPage.where(target_type: "Bean::Merchant", target_id: associated_merchant_ids))
      .or(Bean::CustomPage.where(target_type: "Bean::Store", target_id: associated_store_ids)).ids
  end

  def associated_custom_variant_list_ids
    Bean::CustomVariantList.where(target_type: "Bean::Application", target_id: associated_application_ids)
      .or(Bean::CustomVariantList.where(target_type: "Bean::Merchant", target_id: associated_merchant_ids))
      .or(Bean::CustomVariantList.where(target_type: "Bean::Store", target_id: associated_store_ids)).ids
  end

  def invite(email:)
    self.admin_user = AdminUser.find_by_email(email)

    begin
      transaction do
        unless admin_user
          self.admin_user = AdminUser.new(email: email, password: SecureRandom.hex(24))
          unless self.admin_user.save
            errors.add(:base, self.admin_user.errors.full_messages.join(","))

            raise ActiveRecord::RecordInvalid
          end
        end

        unless store.roles.custom_kind.exists?(id: role_id)
          errors.add(:base, "请选择角色")

          raise ActiveRecord::RecordInvalid
        end

        if store.admin_users_roles.exists?(admin_user_id: admin_user_id)
          errors.add(:base, "已添加过当前账号")

          raise ActiveRecord::RecordInvalid
        end

        save!
      end
    rescue ActiveRecord::RecordInvalid => e
      return false
    end

    true
  end

  private

  def check_platform_valid
    case kind
    when "store"
      errors.add(:store_id, "必填") unless store_id
    when "merchant"
      errors.add(:merchant_id, "必填") unless merchant_id
    when "application"
      errors.add(:application_id, "必填") unless application_id
    end
  end

  def set_platform
    case kind
    when "custom"
      self.store_id = role_store.id
      self.merchant_id = role_store.merchant_id
      self.application_id = role_store.application_id
    when "store"
      self.merchant_id = store.merchant_id
      self.application_id = store.application_id
    when "merchant"
      self.store_id = nil
      self.application_id = merchant.application_id
    when "application"
      self.store_id = nil
      self.merchant_id = nil
    when "super"
      self.store_id = nil
      self.merchant_id = nil
      self.application_id = nil
    end
  end

  def send_invite_email
    AdminUserMailer.with(admin_users_role: self).invite.deliver_later
  end
end
