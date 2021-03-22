# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleStore < ::Entities::Model
    expose :name
  end

  class Store < SimpleStore
  end

  class StoreDetail < Store
  end
end
