# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleTaxon < ::Entities::Model
    expose :name
    expose :parent_id
    expose :position
    expose :taxonomy_id
    expose_attached :icon
  end

  class Taxon < SimpleTaxon
    expose :children, using: SimpleTaxon
    expose :taxonomy, using: SimpleTaxonomy
  end

  class TaxonDetail < Taxon
    expose :parent, using: SimpleTaxon
  end
end
