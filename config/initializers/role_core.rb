# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# For I18n, see `config/locales/role_core.en.yml` for details which followed the rule of ActiveRecord's I18n,
# See <http://guides.rubyonrails.org/i18n.html#translations-for-active-record-models>.

# Uncomment below if you want to integrate with CanCanCan

RoleCore.permission_class = CanCanCanPermission

RoleCore.permission_set_class.draw do
  {
    # Permission CRUD set
    # 以上代码为generator插入代码的标记，请勿修改或删除
  }.each do |group_key, model_name|
    group group_key, model_name: model_name do
      permission :read
      permission :create
      permission :update
      permission :destroy
    end
  end

  # 以下代码为generator插入代码的标记，请勿修改或删除
  # Permission set
  group "application", model_name: "Bean::Application" do
    permission :read_menu
    permission :read_detail_menu
    permission :read do |role|
      { id: role.application_id } unless role.kind == "super"
    end
    permission :create do |role, resource|
      role.kind == "super"
    end
    permission :update do |role, resource|
      role.kind == "super" || role.application_id == resource.id
    end
    permission :update_expired_at do |role, resource|
      role.kind == "super"
    end
  end
  group "merchant", model_name: "Bean::Merchant" do
    permission :read_menu
    permission :read do |role|
      { id: role.associated_merchant_ids } unless role.kind == "super"
    end
    permission :create do |role, resource|
      role.kind == "application"
    end
    permission :update do |role, resource|
      role.associated_merchant_ids.include?(resource.id)
    end
    permission :destroy
  end
  group "store", model_name: "Bean::Store" do
    permission :read_menu
    permission :read do |role|
      { id: role.associated_store_ids } unless role.kind == "super"
    end
    permission :create do |role, resource|
      role.kind == "merchant"
    end
    permission :update do |role, resource|
      role.associated_store_ids.include?(resource.id)
    end
    permission :destroy
  end
  group "admin_user", model_name: "AdminUser" do
    permission :read_menu
    permission :read do |role|
      { id: role.associated_admin_user_ids }
    end
    permission :create do |role, resource|
      role.kind != "custom"
    end
    permission :update do |role, resource|
      role.associated_admin_user_ids.include?(resource.id)
    end
    permission :destroy
  end
  group "admin_users_role", model_name: "AdminUsersRole" do
    permission :read_menu
    permission :read do |role|
      { store_id: role.store_id }
    end
    permission :create do |role, resource|
      resource.custom_kind?
    end
    [:update, :destroy].each do |action|
      permission action do |role, resource|
        resource.custom_kind? && role.store_id == resource.store_id
      end
    end
  end
  group "role", model_name: "Role" do
    permission :read_menu
    permission :read do |role|
      # application、merchant、store类型的角色store_id为nil
      if role.store_id
        { store_id: role.associated_store_ids.push(nil), kind: ["custom"] }
      elsif role.merchant_id
        { store_id: role.associated_store_ids.push(nil), kind: ["merchant", "store", "custom"] }
      elsif role.application_id
        { store_id: role.associated_store_ids.push(nil), kind: ["application", "store", "custom"] }
      end
    end
    permission :create do |role, resource|
      role.kind == "store"
    end
    permission :update, kind: "custom" do |role, resource|
      role.store_id == resource.store_id
    end
    permission :destroy
  end
  group "user", model_name: "User" do
    permission :read_menu
    permission :read do |role|
      { application_id: role.application_id }
    end
  end

  group "page", model_name: "Page" do
    permission :read_menu
    permission :read do |role|
      { application_id: role.application_id }
    end
    permission :update do |role, resource|
      resource.application_id == role.application_id
    end
    [:create, :destroy].each do |action|
      permission action do |role, resource|
        resource.type.eql?("StaticPage") && resource.application_id == role.application_id
      end
    end
  end

  group "custom_page", model_name: "Bean::CustomPage" do
    permission :read_menu
    permission :read do |role|
      { id: role.associated_custom_page_ids }
    end
    [:create, :update, :destroy, :publish, :rollback_data].each do |action|
      permission action do |role, resource|
        associated_target_ids =
          case resource.target_type
          when "Bean::Application"
            role.associated_application_ids
          when "Bean::Merchant"
            role.associated_merchant_ids
          when "Bean::Store"
            role.associated_store_ids
          end
        can = associated_target_ids.include?(resource.target_id)
        action == :destroy ? can && !resource.default : can
      end
    end
  end

  group "custom_variant_list", model_name: "Bean::CustomVariantList" do
    permission :read_menu
    permission :read do |role|
      { id: role.associated_custom_variant_list_ids } unless role.kind == "super"
    end
    [:create, :update, :destroy].each do |action|
      permission action do |role, resource|
        can_manage_target_ids =
          case resource.target_type
          when "Bean::Application"
            role.associated_application_ids
          when "Bean::Merchant"
            role.associated_merchant_ids
          when "Bean::Store"
            role.associated_store_ids
          end
        can_manage_target_ids.include?(resource.target_id) && (action.in?([:create, :destroy]) ? resource.custom? : true)
      end
    end
  end

  [
    "option_type",
    "shipping_template"
  ].each do |name|
    group name, model_name: "Bean::#{name.classify}" do
    permission :read_menu
      permission :read do |role|
        { merchant_id: role.associated_merchant_ids }
      end

      [:create, :update, :destroy].each do |action|
        permission action do |role, resource|
          role.associated_merchant_ids.include?(resource.merchant_id)
        end
      end
    end
  end

  group "option_value", model_name: "Bean::OptionValue" do
    permission :read do |role|
      { option_type: { merchant_id: role.associated_merchant_ids } }
    end

    [:create, :update, :destroy].each do |action|
      permission action do |role, resource|
        role.associated_merchant_ids.include?(resource.option_type.merchant_id)
      end
    end
  end

  group "product", model_name: "Bean::Product" do
    permission :read_menu
    permission :read do |role|
      if role.role.store_kind?
        # 店长或店铺员工可以查看自己商家的商品
        { merchant_id: role.merchant_id }
      else
        { merchant_id: role.associated_merchant_ids }
      end
    end

    [:create, :update, :destroy].each do |action|
      permission action do |role, resource|
        role.associated_merchant_ids.include?(resource.merchant_id)
      end
    end
  end

  group "taxon", model_name: "Bean::Taxon" do
    permission :read_menu
    permission :read do |role|
      { taxonomy: { merchant_id: role.associated_merchant_ids } }
    end

    [:create, :update, :destroy].each do |action|
      permission action do |role, resource|
        role.associated_merchant_ids.include?(resource.taxonomy.merchant_id)
      end
    end
  end

  group "store_variant", model_name: "Bean::StoreVariant" do
    permission :read do |role|
      { store_id: role.associated_store_ids }
    end

    # permission :update do |role, resource|
    #   role.associated_store_ids.include?(resource.store_id)
    # end
  end

  group "payment_method", model_name: "Bean::PaymentMethod" do
    permission :read_menu
    permission :read do |role|
      { application_id: role.application_id }
    end

    [:create, :update, :destroy].each do |action|
      permission action do |role, resource|
        role.associated_application_ids.include?(resource.application_id)
      end
    end
  end

  group "express_service", model_name: "Bean::ExpressService" do
    permission :read_menu
    permission :read do |role|
      { application_id: role.application_id }
    end

    [:create, :update, :destroy].each do |action|
      permission action do |role, resource|
        role.associated_application_ids.include?(resource.application_id)
      end
    end
  end

  group "order", model_name: "Bean::Order" do
    permission :read_menu
    permission :read do |role|
      { store_id: role.associated_store_ids }
    end

    [:update, :audit_refund].each do |action|
      permission action do |role, resource|
        role.associated_store_ids.include?(resource.store_id)
      end
    end
  end

  # group "batch_store_variant_form", model_name: "Bean::BatchStoreVariantForm" do
  #   permission :read do |role|
  #     { store_id: role.associated_store_ids }
  #   end

  #   permission :update do |role, resource|
  #     role.associated_store_ids.include?(resource.store_id)
  #   end
  # end

  group "shipment", model_name: "Bean::Shipment" do
    permission :read do |role|
      { order: { store_id: role.associated_store_ids } }
    end

    [:ship].each do |action|
      permission action do |role, resource|
        role.associated_store_ids.include?(resource.order.store_id)
      end
    end
  end

  group "wtpp_application", model_name: "WechatThirdPartyPlatform::Application" do
    permission :read_menu
    permission :set_weapp_support_version
    permission :read do |role|
      { id: role.associated_wechat_application_ids }
    end
    [:update, :commit, :submit_audit, :release].each do |action|
      permission action do |role, resource|
        role.associated_wechat_application_ids.include?(resource.id)
      end
    end
  end

  group "draft_template", subject: "DraftTemplate" do
    permission :read_menu
    permission :read
    permission :add_to_template
  end

  group "template", subject: "Template" do
    permission :read_menu
    permission :read
    permission :destroy
  end

  group "setting", subject: "Setting" do
    permission :read_menu
    permission :read
    permission :update
  end

  group "register", model_name: "WechatThirdPartyPlatform::Register" do
    permission :create
  end

  group "template_setting", model_name: "WechatThirdPartyPlatform::TemplateSetting" do
    permission :update
  end

  group "tester", model_name: "WechatThirdPartyPlatform::Tester" do
    permission :read_menu
    permission :read do |role|
      { application_id: role.application.wechat_application_id }
    end
    [:create, :destroy].each do |action|
      permission action do |role, resource|
        resource.application_id == role.application.wechat_application_id
      end
    end
  end

  group "wechat_category", subject: "WechatCategory" do
    permission :read
    [:create, :update, :destroy].each do |action|
      permission action do |role, resource|
        role.application&.wechat_application&.platform?
      end
    end
  end

  group "data_analyse", subject: "DataAnalyse" do
    permission :user_portrait
    permission :visit_distribution
    permission :visit_page
    permission :retain_info
    permission :visit_trend
  end

  group "tag", model_name: "ActsAsTaggableOn::Tag" do
    permission :read do |role|
      { taggings: { application_id: role.application_id } }
    end
  end

  group "blob", model_name: "ActiveStorage::Blob" do
    permission :read_menu
    permission :read do |role|
      { application_id: role.application_id }
    end
    [:create, :update, :destroy].each do |action|
      permission action do |role, resource|
        resource.application_id == role.application_id
      end
    end
  end
  # Define permissions for the application. For example:
  #
  #   permission :foo, default: true # `default: true` means grant to user by default
  #   permission :bar
  #
  # You can also group permissions by using `group`:
  #
  #   group :project do
  #     permission :create
  #     permission :destroy
  #     permission :update
  #     permission :read
  #     permission :read_public
  #
  #     # `group` supports nesting
  #     group :task do
  #       permission :create
  #       permission :destroy
  #       permission :update
  #       permission :read
  #     end
  #   end
  #
  # For CanCanCan integration, you can pass `model_name` for `group` or `permission`. For example:
  #
  #   group :project, model_name: "Project" do
  #     permission :create
  #     permission :destroy, model_name: 'Plan'
  #   end
  #
  # That will translate to CanCanCan's abilities (if user has these permissions),
  # the permission's name will be the action:
  #
  #   can :create, Project
  #   can :destroy, Plan
  #
  # You can pass `_priority` argument to `permission`
  #
  #   group :project, model_name: "Project" do
  #     permission :read_public,
  #     permission :read, _priority: 1
  #   end
  #
  # That will made 'read' prior than `read_public`.
  #
  # For CanCanCan's hash of conditions
  # (see https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities#hash-of-conditions)
  # you can simply pass them as arguments for `permission` even with a block
  #
  #   group :task, model_name: "Task" do
  #     permission :read_public, is_public: true
  #     permission :update_my_own, action: :update, default: true do |user, task|
  #       task.user_id == user.id
  #     end
  #   end
  #
  # Although permission's name will be CanCanCan's action by default,
  # you can pass `action` argument to override it.
  #
  #   permission :read_public, action: :read, is_public: true
  #
  # For some reason, you won't interpret the permission to CanCanCan,
  # you can set `_callable: false` to `permission` or `group`
  #
  #   permission :read, _callable: false
  #
end.finalize! # Call `finalize!` to freezing the definition, that's optional.
