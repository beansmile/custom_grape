# frozen_string_literal: true

module AppAPI::Entities::Bean
  class SimpleTaxon < ::Entities::Model
    expose :name
    expose :parent_id
    expose :taxonomy_id
    expose_attached :icon
  end

  class Taxon < SimpleTaxon
    expose :children, using: SimpleTaxon
  end

  class TaxonDetail < Taxon
    expose :parent, using: SimpleTaxon
    expose :taxonomy, using: SimpleTaxonomy
  end
end
