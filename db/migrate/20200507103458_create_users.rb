# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :screen_name, null: false, default: ""
      t.string :tracking_code, null: false, index: { unique: true }
      t.datetime :sns_authorized_at

      t.timestamps null: false
    end
  end
end
