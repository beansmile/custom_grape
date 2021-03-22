# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleVariant < ::Entities::Model
  end

  class Variant < SimpleVariant
  end

  class VariantDetail < Variant
  end
end
