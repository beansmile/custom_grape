# frozen_string_literal: true

class CreateBeanApplications < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_applications do |t|
      t.string :name
      t.string :appid
      t.string :secret

      t.timestamps
    end
  end
end
