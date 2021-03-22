# frozen_string_literal: true

class CreateBeanOptionValues < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_option_values do |t|
      t.string :name
      t.integer :position
      t.belongs_to :option_type, null: false, foreign_key: { to_table: "bean_option_types" }

      t.timestamps
    end
  end
end
