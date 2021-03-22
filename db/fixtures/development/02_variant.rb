# frozen_string_literal: true

Bean::Variant.seed do |v|
  v.id = 1
  v.sku = "001"
  v.product_id = 1
  v.weight = 1
  v.is_active = true
end

Bean::OptionValueVariant.seed(
  :id,
  { id: 1, variant_id: 1, option_value_id: 1 },
  { id: 2, variant_id: 1, option_value_id: 3 }
)

Bean::StockLocationItem.seed do |sli|
  sli.id = 1
  sli.stock_location_id = 1
  sli.variant_id = 1
  sli.count_on_hand = 999
end
