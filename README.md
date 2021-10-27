## Install

```
gem "custom_grape", github: "beansmile/custom_grape", branch: "v3"
```

```
rails g custom_grape:install
```

`config/initializers` 目录下文件加入以下代码

```
class Grape::API::Instance
  extend CustomGrape::Custom::DSLMethods
end
```

## Usage

### Grape基础用法

以下 `custom_index`、`custom_show`、`custom_create`、`custom_update`、`custom_destroy` 在 `rails g custom_grape:install` 命令生成文件里，可根据项目需求更改或新增

```
class AppAPI::V1::ProductCategories < API
  include Grape::Kaminari

  custom_namespace "product_categories" do
    params do
      optional :name_cont
    end
    custom_index

    params do
      requires :name
    end
    custom_create

    custom_route_param :id do
      custom_show

      params do
        requires :name
      end
      custom_update

      custom_destroy
    end
  end
end
```

### Grape entity基础用法

```
module AppAPI::Entities
  class SimpleProductCategory < ::Entities::Model
    custom_expose :name # 用custom_expose，会自动填充属性的类型，描述
  end

  class ProductCategory < SimpleProductCategory
    custom_expose :image # 使用custom_expose，会自动判断是否ActiveStorage，是的话自动使用对应的entity
    custom_expose :products # 使用custom_expose，会自动判断是否关联关系， 是的话自动使用对应的Simple entity，可使用using参数覆盖
  end

  class ProductCategoryDetail < ProductCategory
  end
end
```
