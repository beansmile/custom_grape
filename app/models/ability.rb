# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user = nil)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    if user
      send("#{user.class.name.underscore}_abilities", user)
    else
      guest_abilities
    end
  end

  # admin用户通过role获取权限
  def admin_users_role_abilities(role)
    role.computed_permissions.call(self, role)
  end

  def user_abilities(user)
    guest_abilities

    can :read, user
    can :read, Page, status: :published, application_id: user.application_id
    can :read, Bean::Taxon, taxonomy_id: user.application.taxonomy_ids
    can :read, Bean::CustomPage, target_type: "Bean::Application", target_id: user.application_id
    can :read, Bean::CustomPage, target_type: "Bean::Merchant", target_id: user.application.associated_merchant_ids
    can :read, Bean::CustomPage, target_type: "Bean::Store", target_id: user.application.associated_store_ids

    can :read, Bean::CustomVariantList, target_type: "Bean::Application", target_id: user.application_id
    can :read, Bean::CustomVariantList, target_type: "Bean::Merchant", target_id: user.application.associated_merchant_ids
    can :read, Bean::CustomVariantList, target_type: "Bean::Store", target_id: user.application.associated_store_ids

    can :read, Bean::Application, id: user.application_id

    store_variant_condition = Bean::StoreVariant.joins(variant: [product: :merchant]).where(is_active: true, bean_merchants: { application_id: user.application_id, is_active: true }).
      where("bean_products.discontinue_on IS NULL OR bean_products.discontinue_on > ?", Time.current).
      where("bean_products.available_on IS NULL OR bean_products.available_on <= ?", Time.current)

    can :read, Bean::StoreVariant, store_variant_condition do |store_variant|
      store_variant.active? && user.application_id == store_variant.variant.product.merchant.application_id
    end

    if user.sns_authorized
      can [:read, :create, :update, :destroy], Bean::ShoppingCartItem, shopping_cart_id: user.shopping_cart_id
      can [:preview, :create, :request_payment, :read, :destroy, :apply_refund, :close, :receive], Bean::Order, user: user
      can :read, Bean::Country
      can :read, Bean::Province
      can :read, Bean::City
      can :read, Bean::District
      can :manage, Bean::Address, user: user
      can :read, Bean::PaymentMethod, is_active: true, application_id: user.application_id
    end
  end

  def guest_abilities
    can :read, Setting
    can :read, Banner
  end
end
