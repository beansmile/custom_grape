# frozen_string_literal: true

Bean::StoreVariant.seed do |sv|
  sv.id = 1
  sv.cost_price = 100
  sv.origin_price = 110
  sv.is_active = true
  sv.variant_id = 1
  sv.store_id = 1
  sv.is_master = true
end
