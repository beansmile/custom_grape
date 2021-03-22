# frozen_string_literal: true

class AppAPI::V1::Bean::ShoppingCartItemGroups < API
  namespace "bean/shopping_cart_item_groups" do
    desc "购物车商品（多店）", {
      summary: "购物车商品（多店）",
      success: AppAPI::Entities::Bean::ShoppingCartItemGroup
    }
    get do
      authorize! :read, Bean::ShoppingCartItem

      store_groups = current_user.shopping_cart.shopping_cart_items.includes(:store_variant).order("bean_shopping_cart_items.id DESC").group_by { |item| item.store_variant.store_id }

      store_shopping_cart_items = store_groups.keys.map do |store_id|
        {
          store: Bean::Store.find(store_id),
          shopping_cart_items: store_groups[store_id]
        }
      end

      present store_shopping_cart_items, with: AppAPI::Entities::Bean::ShoppingCartItemGroup
    end
  end
end
