# frozen_string_literal: true

class AddTargetToBeanCustomPages < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :bean_custom_pages, :target, polymorphic: true
  end
end
