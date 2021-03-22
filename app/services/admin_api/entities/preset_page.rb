# frozen_string_literal: true
module AdminAPI::Entities
  class SimplePresetPage < ::Entities::Model
    expose :title
    expose :slug
    expose :views_count
  end

  class PresetPage < SimplePresetPage
  end

  class PresetPageDetail < PresetPage
    expose :content
  end
end
