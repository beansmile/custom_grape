# frozen_string_literal: true
module AdminAPI::Entities::ActsAsTaggableOn
  class SimpleTag < ::Entities::Model
    expose :name
  end

  class Tag < SimpleTag
  end

  class TagDetail < Tag
  end
end
