# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimplePaymentMethod < ::Entities::Model
    expose :name
    expose :is_active
    expose :type
    expose :configuration
    expose :uploaded_apiclient_cert do |resource|
      resource.apiclient_cert.present?
    end
  end

  class PaymentMethod < SimplePaymentMethod
  end

  class PaymentMethodDetail < PaymentMethod
  end
end
