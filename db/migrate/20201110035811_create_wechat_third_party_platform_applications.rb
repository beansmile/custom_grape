# frozen_string_literal: true

class CreateWechatThirdPartyPlatformApplications < ActiveRecord::Migration[6.0]
  def change
    create_table :wechat_third_party_platform_applications do |t|
      t.string :appid , index: { unique: true }
      t.integer :account_type
      t.integer :principal_type
      t.string :principal_name
      t.string :access_token
      t.string :refresh_token
      t.jsonb :func_info, default: [], array: true
      t.references :register, foreign_key: { to_table: "wechat_third_party_platform_registers" }, index: { name: "index_wtpp_applications_on_register_id" }
      t.integer :source, default: 0
      t.string :nick_name, comment: "昵称"
      t.string :user_name, comment: "原始 ID"
      t.jsonb :mini_program_info, default: {}
      t.string :new_name
      t.integer :name_changed_status, default: 0
      t.string :name_rejected_reason
      t.integer :authorization_status, default: 0

      t.timestamps
    end
  end
end
