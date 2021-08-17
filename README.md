## Usage

* 一般使用场景以 `app_api/v1/products.rb` 来举例，hash参数不需要填写，默认参数会根据文件名生成，以下把生成的参数都列出来

```
apis :index, :show, :create, :update, :destroy, {
  # 是否跳过用户登录验证，默认为false
  skip_authentication: false,
  # 如需通过slug查找对象则把id替换成slug
  find_by_key: :id
  resource_class: Product,
  resource_entity: AppAPI::Entities::ProductDetail,
  collection_entity: AppAPI::Entities::Product，
  # 如不填则生成 products namespace，如填写mine，则生成 mine/products namespace
  namespace: nil,
  # 如填写 :product_category 则生成 product_categories/:product_category_id/products namespace，可调用 parent 方法获取 product_category
  belongs_to: nil,
  # 不填写则会根据belongs_to配置生成 product_category_id，如填写则 :slug 则生成 product_categories/:slug/products
  belongs_to_find_by_key: nil
}
```

* 如需要重写API，可重定义action名+_api覆盖（如重写index则在helpers里创建index_api）

```
apis :index, :show, :create, :update, :destroy do
  helpers do
    def index_api
      # 重写内容
    end
  end
end
```

* index API会自动根据index_params过滤掉没有定义的查找参数（ransack太自由，这里加白名单限制）

```
apis :index do
  helpers do
    params :index_params do
      optional :title_eq
    end
  end
end
```

* create和update API会根据自动create_params和update_params生成permitted_params（需定义好type，尤其是Array[JSON]这种数据类型）

```
apis :create, :update do
  helpers do
    params :create_params do
      optional :name, type: String
      optional :tag_ids: type: Array[Integer]
      optional :comment_attributes, type: Array[JSON] do
        optional :content, type: String
      end
    end
  end
end
```

* 可为API单独配置参数

```
apis [
  create: { tags: ["create"] },
  :update
] do
  ...
end
```

