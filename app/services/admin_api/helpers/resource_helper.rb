# frozen_string_literal: true

module AdminAPI::Helpers
  module ResourceHelper
    include CustomGrape::ResourceHelper

    def entity_namespace_name
      "::AdminAPI::Entities"
    end

    def ability_user
      @ability_user ||= current_role
    end
  end
end
