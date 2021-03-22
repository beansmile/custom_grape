# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleOptionValue < ::Entities::Model
    expose :name
  end

  class OptionValue < SimpleOptionValue
    expose :option_type, using: SimpleOptionType
  end

  class OptionValueDetail < OptionValue
  end
end
