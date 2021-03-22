# frozen_string_literal: true

class CreateBeanShareSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_share_settings do |t|
      t.string :share_words
      t.belongs_to :target, polymorphic: true
      t.belongs_to :store

      t.timestamps
    end
  end
end
