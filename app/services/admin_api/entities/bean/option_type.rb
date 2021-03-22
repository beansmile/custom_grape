# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleOptionType < ::Entities::Model
    expose :name
  end

  class OptionType < SimpleOptionType
    expose :option_values, using: SimpleOptionValue
  end

  class OptionTypeDetail < OptionType
    expose :option_values, using: OptionValue
  end
end
