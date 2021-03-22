# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleOptionValue < ::Entities::Model
    expose :name
    expose :option_type_id
  end

  class OptionValue < SimpleOptionValue
  end

  class OptionValueDetail < OptionValue
  end
end
