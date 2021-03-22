# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration[6.0]
  def change
    create_table :pages do |t|
      t.text :content
      t.string :title, null: false
      t.string :type, null: false
      t.string :slug, null: false, index: { unique: true }
      t.integer :status, default: 0
      t.integer :views_count, default: 0

      t.timestamps null: false
    end
  end
end
