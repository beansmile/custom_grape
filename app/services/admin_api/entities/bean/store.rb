# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleStore < ::Entities::Model
    expose :name
    expose :merchant_id
    expose :discontinue_on
  end

  class Store < SimpleStore
    expose :merchant, using: SimpleMerchant
  end

  class StoreDetail < Store
  end
end
