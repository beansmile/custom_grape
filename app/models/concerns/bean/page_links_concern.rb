 # frozen_string_literal: true

module Bean
  module PageLinksConcern
    extend ActiveSupport::Concern

    FIXED_PAGES = {
      "首页": "/pages/root/home",
      "我的": "/pages/root/mine",
      "购物车": "/pages/root/shopping-cart",
      "分类列表": "/pages/root/category",
      "全部商品列表": "/pages/products/list",
    }

    class_methods do
      def grouped_links(current_role = nil)
        result = Hash.new { |hash, key| hash[key] = {} }

        result["固定页面"] = { type: "fixed_page", links: FIXED_PAGES }

        # detail_page类型的model中需定义mini_program_path_name、mini_program_path方法和BASE_PATH常量
        result["商品详情"] = {
          type: "detail_page",
          collection: -> (keyword = nil) {
            Bean::StoreVariant.master.ransack(store_id_in: current_role&.associated_store_ids, variant_product_name_cont: keyword).result
          },
          find_by_key: "id"
        }
        result["自定义页面"] = {
          type: "detail_page",
          collection: -> (keyword = nil) {
            Bean::CustomPage.formal.ransack(id_in: current_role&.associated_custom_page_ids, name_cont: keyword).result
          },
          find_by_key: "en_name"
        }
        result["自定义商品列表"] = {
          type: "detail_page",
          collection: -> (keyword = nil) {
            Bean::CustomVariantList.ransack(id_in: current_role&.associated_custom_variant_list_ids, title_cont: keyword).result
          },
          find_by_key: "id"
        }
        result["独立页面"] = {
          type: "detail_page",
          collection: -> (keyword = nil) {
            Page.ransack(application_id_eq: current_role&.application_id, title_cont: keyword).result
          },
          find_by_key: "id"
        }

        result
      end

      # 返回结果：
      # {
      #   "/pages/root/home": { link_name: #<Proc:...(lambda)> },
      #   "pages/products/detail": { find_by_key: "id", link_name: #<Proc:...(lambda)> },
      #   ...
      # }
      def link_properties(current_role = nil)
        grouped_links.values.map do |grouped_link|
          if grouped_link[:type] == "fixed_page"
            grouped_link[:links].map { |k, v| [v, { link_name: -> (key) { k.to_s } }] } # 跟detail_page类型统一格式，方便处理
          elsif grouped_link[:type] == "detail_page"
            model = grouped_link[:collection].call.model
            find_by_key = model.respond_to?(:friendly) ? model.friendly_id_config.base : grouped_link[:find_by_key]
            [["/#{model::BASE_PATH}", {
              find_by_key: grouped_link[:find_by_key],
              link_name: -> (key) { grouped_link[:collection].call.find_by(find_by_key => key)&.mini_program_path_name }
            }]]
          end
        end.flatten(1).to_h
      end
    end

    def link_name(link, current_role = nil)
      uri = Addressable::URI.parse(link)
      link_property = self.class.link_properties(current_role)[uri.path]
      link_property&.dig(:link_name)&.call(uri.query_values&.dig(link_property[:find_by_key]))
    end
  end
end
