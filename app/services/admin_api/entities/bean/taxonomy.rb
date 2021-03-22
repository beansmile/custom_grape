# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleTaxonomy < ::Entities::Model
    expose :name
    expose :merchant_id
    expose :position
    expose :taxonomy_type
  end

  class Taxonomy < SimpleTaxonomy
  end

  class TaxonomyDetail < Taxonomy
    expose :merchant, using: SimpleMerchant
  end
end
