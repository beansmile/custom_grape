# frozen_string_literal: true

class AppAPI::V1::Bean::PaymentMethods < API
  include Grape::Kaminari

  apis :index
end
