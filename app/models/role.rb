# frozen_string_literal: true

class Role < RoleCore::Role
  # constants
  STATIC_PERMISSION_MODEL = [
    :application,
    :merchant,
    :store,
    :admin_user,
    :admin_users_role,
    :role,
    :store_variant,
    :wtpp_application,
    :template,
    :draft_template,
    :register,
    :template_setting,
    :setting,
    :tag,
    :option_value,
    :express_service,
  ]

  # concerns
  include RolePermissionsConcern

  # attr related macros
  enum kind: {
    custom: 0,
    super: 1,
    application: 2,
    merchant: 3,
    store: 4
  }, _suffix: true

  # association macros
  belongs_to :store, class_name: "Bean::Store", optional: true
  has_and_belongs_to_many :admin_users, dependent: :restrict_with_error

  # validation macros
  validates :name, uniqueness: { scope: :store_id }, presence: true
  validate :check_store_valid

  # callbacks
  before_save :set_permissions

  # other macros

  # scopes

  # class methods
  def self.permissions_hash
    @@permissions_hash ||= self.new.permissions.to_h.select do |key|
      STATIC_PERMISSION_MODEL.exclude?(key)
    end.merge({
      application: { read: false, update: false }
    })
  end

  def self.cached_i18n
    @@cached_i18n ||= {}
    @@cached_i18n if @@cached_i18n.present?
    role_core_i18n = I18n.t(".role_core")
    role_core_i18n[:models] = new.permissions.to_h.keys.inject({}) do |hash, model_name|
      hash[model_name] = I18n.t("role_core.models.#{model_name}", default: [:"activerecord.models.#{model_name}", model_name] )

      hash
    end
    @@cached_i18n = role_core_i18n
  end

  # instance methods
  def permissions_attributes
    permissions.to_h
  end

  def permissions_attributes=(value)
    permissions.update_attributes value
  end

  def cached_i18n
    self.class.cached_i18n
  end

  # 除了自定义角色，其他角色权限不可编辑
  def set_permissions
    self.permissions_attributes = if custom_kind?
                                    custom_permissions.deep_symbolize_keys!
                                    data = custom_permissions.deep_dup

                                    custom_permissions.each do |model_name, actions|
                                      # 暂时先根据model_name来写逻辑做权限扩展的逻辑处理，后续再考虑写成可配置
                                      if model_name == :product
                                        data[:taxon] ||= {}
                                        data[:shipping_template] ||= {}
                                        data[:option_type] ||= {}
                                        data[:option_value] ||= {}

                                        if actions[:create] || actions[:update]
                                          data[:taxon][:read] = true
                                          data[:shipping_template][:read] = true
                                          data[:option_type][:read] = true
                                          data[:option_type][:create] = true
                                          data[:option_type][:update] = true
                                          data[:option_value][:read] = true
                                          data[:option_value][:create] = true
                                          data[:option_value][:update] = true
                                        end
                                      elsif model_name == :custom_page
                                        if actions[:create] || actions[:update]
                                          data[:custom_variant_list] ||= {}
                                          data[:custom_variant_list][:read] = true
                                        end
                                      elsif model_name == :custom_variant_list
                                        if actions[:create] || actions[:update]
                                          data[:store_variant] ||= {}
                                          data[:store_variant][:read] = true
                                        end
                                      elsif model_name == :blob
                                        if actions[:read] || actions[:create] || actions[:update]
                                          data[:tag] ||= {}
                                          data[:tag][:read] = true
                                        end
                                      end

                                      if model_name == :application
                                        data[model_name][:read_detail_menu] = true if actions[:read]
                                      else
                                        data[model_name][:read_menu] = true if actions[:read]
                                      end
                                    end

                                    data.merge(custom_permissions_attributes)
                                  else
                                    # 方法定义见RolePermissoinsConcern
                                    send("#{kind}_permissions_attributes")
                                  end
  end


  private

  def check_store_valid
    return if Rails.env.test?
    errors.add(:base, "请先选择店铺再编辑") if custom_kind? && store.blank?
  end
end
