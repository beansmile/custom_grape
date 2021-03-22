# frozen_string_literal: true

class CreateWechatThirdPartyPlatformSubmitions < ActiveRecord::Migration[6.0]
  def change
    create_table :wechat_third_party_platform_submitions do |t|
      t.string :template_id
      t.json :ext_json, default: {}
      t.json :audlt_result, default: {}
      t.string :user_version
      t.string :user_desc
      t.integer :state, default: 0
      t.integer :application_id

      t.timestamps
    end

    add_index :wechat_third_party_platform_submitions, :application_id
    add_index :wechat_third_party_platform_submitions, :template_id
  end
end
