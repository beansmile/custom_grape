# frozen_string_literal: true

Bean::Product.seed do |p|
  p.id = 1
  p.name = "商品A"
  p.merchant_id = 1
  p.shipping_template_id = 1
  p.taxon_ids = [1]
end

Bean::ProductOptionType.seed(
  :id,
  { id: 1, product_id: 1, option_type_id: 1 },
  { id: 2, product_id: 1, option_type_id: 2 }
)
