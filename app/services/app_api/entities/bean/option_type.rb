# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleOptionType < ::Entities::Model
    expose :name
  end

  class OptionType < SimpleOptionType
  end

  class OptionTypeDetail < OptionType
  end
end
