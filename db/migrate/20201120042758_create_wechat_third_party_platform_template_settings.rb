class CreateWechatThirdPartyPlatformTemplateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :wechat_third_party_platform_template_settings do |t|
      t.integer :latest_template_id

      t.timestamps
    end
  end
end
