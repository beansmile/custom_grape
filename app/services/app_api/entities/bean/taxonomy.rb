# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleTaxonomy < ::Entities::Model
    expose :name
    expose :position
    expose :merchant_id
    expose :taxonomy_type
  end

  class Taxonomy < SimpleTaxonomy
  end

  class TaxonomyDetail < Taxonomy
  end
end
