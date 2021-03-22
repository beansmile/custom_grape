# frozen_string_literal: true

class RemoveStoreIdInBeanCustomPages < ActiveRecord::Migration[6.0]
  def change
    remove_belongs_to :bean_custom_pages, :store
  end
end
