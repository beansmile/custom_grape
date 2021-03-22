# frozen_string_literal: true

module RolePermissionsConcern
  extend ActiveSupport::Concern

  def only_read_permissions
    @only_read_permissions ||= Role.permissions_hash.each { |model, permissions| permissions[:read] = true }
  end

  def super_permissions_attributes
    Role.new.permissions.to_h.merge({
      application: { read_menu: true, read: true, update_expired_at: true },
      wtpp_application: { read_menu: true, read: true, commit: true, submit_audit: true, release: true, update: true, set_weapp_support_version: true },
      draft_template: { read_menu: true, read: true, add_to_template: true },
      template: { read_menu: true, read: true, destroy: true },
      setting: { read_menu: true, read: true, update: true },
      template_setting: { update: true }
    })
  end

  # TODO SAAS版暂无该角色，添加该角色后需要更新权限数据
  def application_permissions_attributes
    only_read_permissions.merge({
      application: { read: true, update: true },
      merchant: {},
      store: { read: true, create: true, update: true, destroy: true },
      admin_user: { read: true, create: true, update: true, destroy: true },
      role: { read: true },
      custom_page: { read: true, create: true, update: true, destroy: true },
      payment_method: { read: true, create: true, update: true, destroy: true },
      page: { read: true }
    })
  end

  # TODO SAAS版暂无该角色，添加该角色后需要更新权限数据
  def merchant_permissions_attributes
    only_read_permissions.merge({
      merchant: { read: true, update: true },
      store: { read: true, create: true, update: true, destroy: true },
      admin_user: { read: true, create: true, update: true, destroy: true },
      role: { read: true },
      shipping_template: { read: true, create: true, update: true, destroy: true },
      option_type: { read: true, create: true, update: true, destroy: true },
      option_value: { read: true, create: true, update: true, destroy: true },
      product: { read: true, create: true, update: true, destroy: true },
      taxon: { read: true, create: true, update: true, destroy: true },
      page: { read: true, update: true, destroy: true, create: true }
    })
  end

  # SASS版没有商家管理员，需要放大店长的权限，店长可以做商家的一些操作
  def store_permissions_attributes
    Role.new.permissions.to_h.merge(
      Role.permissions_hash.deep_transform_values { true }
    ).merge({
      application: { read_detail_menu: true, read: true, update: true },
      admin_users_role: { read_menu: true, read: true, create: true, update: true, destroy: true },
      role: { read_menu: true, read: true, create: true, update: true, destroy: true },
      shipment: { read: true, ship: true },
      register: { create: true },
      setting: { read: true },
      wtpp_application: { submit_audit: true, release: true },
      store_variant: { read: true },
      tag: { read: true },
      option_value: { read: true, create: true, update: true, destroy: true },
      express_service: { read_menu: true, read: true, create: true, update: true, destroy: true }
    })
  end

  def custom_permissions_attributes
    {
      setting: { read: true }
    }
  end
end
