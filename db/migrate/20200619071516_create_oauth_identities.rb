# frozen_string_literal: true

class CreateOauthIdentities < ActiveRecord::Migration[6.0]
  def change
    create_table :oauth_identities do |t|
      t.string :provider, null: false, default: ""
      t.string :primary_uid, null: false, default: ""
      t.string :secondary_uid
      t.json :credentials, null: false, default: {}
      t.json :user_info, null: false, default: {}
      t.json :extra, null: false, default: {}
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :oauth_identities, :primary_uid
    add_index :oauth_identities, :secondary_uid
  end
end
