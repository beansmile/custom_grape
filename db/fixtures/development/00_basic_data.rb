# frozen_string_literal: true

Bean::Application.seed do |a|
  a.id = 1
  a.appid = "wx7dd9520884e4b929"
  a.name = "小程序A"
end

User.seed do |u|
  u.id = 1
  u.screen_name = "用户A"
  u.application_id = 1
  u.tracking_code = "1"
  u.sns_authorized_at = Time.current
end

Bean::ShoppingCart.seed do |sc|
  sc.id = 1
  sc.user_id = 1
end

PresetPage.seed do |pp|
  pp.id = 1
  pp.title = "关于我们"
  pp.slug = "about_us_app_1"
  pp.content = "关于我们页面"
  pp.status = "published"
  pp.application_id = 1
end

Bean::Merchant.seed do |m|
  m.id = 1
  m.name = "商家A"
  m.application_id = 1
  m.is_active = true
  m.free_freight_amount = 100
end

Bean::Taxonomy.seed do |t|
  t.id = 1
  t.name = "分类"
  t.merchant_id = 1
  t.taxonomy_type = :category
end

Bean::Taxon.seed do |t|
  t.id = 1
  t.name = "一级分类"
  t.taxonomy_id = 1
end

Bean::Taxon.seed do |t|
  t.id = 2
  t.name = "二级分类"
  t.taxonomy_id = 1
  t.parent_id = 1
end

Bean::Store.seed do |s|
  s.id = 1
  s.name = "店铺A"
  s.merchant_id = 1
end

Bean::StockLocation.seed do |sl|
  sl.id = 1
  sl.name = "仓库A"
end

Bean::StoreStockLocation.seed do |ssl|
  ssl.id = 1
  ssl.store_id = 1
  ssl.stock_location_id = 1
end

Bean::ShoppingCart.seed do |sc|
  sc.id = 1
  sc.user_id = 1
end

Bean::OptionType.seed(
  :id,
  { id: 1, name: "颜色", merchant_id: 1 },
  { id: 2, name: "尺寸", merchant_id: 1 },
)

Bean::OptionValue.seed(
  :id,
  { id: 1, name: "红色", option_type_id: 1 },
  { id: 2, name: "蓝色", option_type_id: 1 },
  { id: 3, name: "XL", option_type_id: 2 },
  { id: 4, name: "XXL", option_type_id: 2 },
)

Bean::ShippingTemplate.seed(
  :id,
  { id: 1, merchant_id: 1, name: "运费模板A", calculate_type: :weight }
)

Bean::ShippingCategory.seed(
  :id,
  { id: 1, name: "快递", shipping_template_id: 1 }
)

Bean::ShippingMethod.seed(
  :id,
  { id: 1, name: "默认", is_default: true, shipping_category_id: 1 }
)

Bean::Calculator::Shipping::Weight.seed(
  :id,
  { id: 1, calculable_type: "Bean::ShippingMethod", calculable_id: 1, preferences: { first_weight: "1", first_weight_price: "6", continued_weight: "1", continued_weight_price: "0" } }
)
