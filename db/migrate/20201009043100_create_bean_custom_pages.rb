# frozen_string_literal: true

class CreateBeanCustomPages < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_custom_pages do |t|
      t.string :name
      t.string :en_name
      t.json :components, default: []
      t.boolean :default, default: false
      t.belongs_to :store

      t.timestamps
    end
  end
end
