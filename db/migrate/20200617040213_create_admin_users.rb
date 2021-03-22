# frozen_string_literal: true

class CreateAdminUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_users do |t|
      t.string :email
      t.string :phone
      t.string :password_digest, null: false
      t.string :name
      t.string :reset_password_token
      t.string :reset_password_sent_at

      t.timestamps
    end
  end
end
