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

### Grape entity

#### 自动识别关联model

支持以下3种格式

- AppAPI::Entities::Simple#{model_name}（如AppAPI::Entities::SimpleProductCategory）
- AppAPI::Entities::#{model_name}（如AppAPI::Entities::ProductCategory）
- AppAPI::Entities::#{model_name}Detail（如AppAPI::Entities::ProductCategoryDetail）

如Entity name不符合上面3种格式，可按下面方法重写

```
module AppAPI::Entities
  class Mine < ::Entities::Model
    def self.fetch_model
      ::User
    end

    custom_expose :name
  end
end
```

如Entity namespace默认为前两个，如 `AppAPI::Entities::ProductCategory` 的namespace为 `AppAPI::Entities`，自动识别关联model时会去除namespace，如不符合默认规则，可按下面方法重写

```
module AppAPI::Entities
  class SimpleProductCategory < ::Entities::Model
    def self.entity_namespace
      # 默认逻辑
      # self.to_s.split("::")[0..1].join("::")
      self.to_s.split("::")[0..2].join("::")
    end

    custom_expose :name
  end
end
```

#### 自动生成documentation参数

```
module AppAPI::Entities
  class ProductCategory < ::Entities::Model
    custom_expose :name
    custom_expose :products
    custom_expose :image_attachment, as: :image # has_one_attach :image时需要写成这样
  end
end
```

- desc：根据ProductCategory.human_attribute_name(:name)生成
- type：根据数据表属性，关联关系生成
- using: 如检测到是关联关系，则自动生成using: "Simple#{class_name}"

#### only和except

```
module AppAPI::Entities
  class SimpleProductCategory < ::Entities::Model
    custom_expose :name
    custom_expose :product_categories, only: [:name]
  end
end
```

传only和except参数，可选择关联关系返回的数据，这样就可以把一些关联关系放到Simple entity而不用担心关联数据太多，或无限循环调用的问题了


#### 提供includes配置

```
module AppAPI::Entities
  class User < ::Entities::Model
    custom_expose :profile_name, includes: [:profile]
  end
end
```

调用 `CustomGrape::Includes.fetch("AppAPI::Entities::User").fetch_includes` 可得到结果 `[:profile]`


```
module AppAPI::Entities
  class User < ::Entities::Model
    custom_expose :profile_name, includes: [:profile]
    custom_expose :friends # 关联关系会自动生成includes，可通过传includes覆盖
  end
end
```

调用 `AppAPI::Entities::User.includes` 时，如果检测到 `friends` 是关联关系，则会递归调用 `AppAPI::Entities::SimpleFriend.includes` 直到检测不到关联关系为止
