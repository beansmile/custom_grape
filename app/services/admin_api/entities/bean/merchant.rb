# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleMerchant < ::Entities::Model
    expose :name
    expose :application_id
    expose :is_active
  end

  class Merchant < SimpleMerchant
    expose :application, using: SimpleApplication
  end

  class MerchantDetail < Merchant
  end
end
