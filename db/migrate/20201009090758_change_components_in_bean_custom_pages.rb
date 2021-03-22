# frozen_string_literal: true

class ChangeComponentsInBeanCustomPages < ActiveRecord::Migration[6.0]
  def up
    change_column(:bean_custom_pages, :components, :jsonb, default: [])
  end

  def down
    change_column(:bean_custom_pages, :components, :json, default: [])
  end
end
