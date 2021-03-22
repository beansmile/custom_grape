# frozen_string_literal: true

class CreateBeanOptionTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_option_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
