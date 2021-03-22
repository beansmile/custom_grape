# frozen_string_literal: true

module AppAPI::Helpers
  module ResourceHelper
    include CustomGrape::ResourceHelper

    def entity_namespace_name
      "::AppAPI::Entities"
    end
  end
end
