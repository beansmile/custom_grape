# frozen_string_literal: true

# frozen_string_literal: true

class AdminAPI::V1::Bean::PageLinks < API
  include Grape::Kaminari

  namespace "bean/page_links", desc: "小程序页面链接" do
    desc "获取小程序页面类型", detail: <<-NOTES.strip_heredoc
      ```json
      [
        "固定页面",
        "单个产品",
        "自定义页面",
        "自定义商品列表",
        "独立页面"
      ]
      ```
    NOTES
    get "types" do
      Bean::CustomPage.grouped_links.keys
    end

    desc "获取小程序页面链接", detail: <<-NOTES.strip_heredoc
      ```json
      [
        { "育儿师": "/pages/products/detail/1" },
        { "月嫂": "/pages/products/detail/2" }
      ]
      ```
    NOTES
    paginate
    params do
      requires :type, type: String, values: Bean::CustomPage.grouped_links.keys
      optional :keyword, type: String
    end
    get do
      value = Bean::CustomPage.grouped_links(current_role)[params[:type]]

      result =
        if value[:type] == "fixed_page"
          paginate(Kaminari.paginate_array(
            value[:links].keys.map { |key| [[key, value[:links][key]]].to_h }
          ))
        elsif value[:type] == "detail_page"
          paginate(value[:collection].call(params[:keyword])).map do |resource|
            [[resource.mini_program_path_name, "/#{resource.mini_program_path}"]].to_h
          end
        end
      present result
    end
  end
end
