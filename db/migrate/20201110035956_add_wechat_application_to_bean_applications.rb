class AddWechatApplicationToBeanApplications < ActiveRecord::Migration[6.0]
  def change
    add_reference :bean_applications, :wechat_application, foreign_key: { to_table: "wechat_third_party_platform_applications" }
  end
end
