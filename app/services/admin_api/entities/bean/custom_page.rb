# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleCustomPage < ::Entities::Model
    expose :title
    expose :slug
    expose :default
  end

  class CustomPage < SimpleCustomPage
    expose :formal_custom_page_id
    expose :can_rollback_data?, as: :can_rollback_data
  end

  class CustomPageDetail < CustomPage
    expose :configs
  end
end
