# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimplePaymentMethod < ::Entities::Model
    expose :name
    expose :type
  end

  class PaymentMethod < SimplePaymentMethod
  end

  class PaymentMethodDetail < PaymentMethod
  end
end
