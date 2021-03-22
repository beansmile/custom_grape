# frozen_string_literal: true

class CreateBanners < ActiveRecord::Migration[6.0]
  def change
    create_table :banners do |t|
      t.string :kind
      t.jsonb :target, default: {}
      t.integer :position, default: 0
      t.integer :page_position, default: 0
      t.string :alt

      t.timestamps
    end
  end
end
