# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleExpressService < ::Entities::Model
    expose :name
    expose :is_active
    expose :type
    expose :configs
  end

  class ExpressService < SimpleExpressService
  end

  class ExpressServiceDetail < ExpressService
  end
end
