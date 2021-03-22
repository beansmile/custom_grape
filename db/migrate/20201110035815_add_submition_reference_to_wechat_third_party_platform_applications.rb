# frozen_string_literal: true

class AddSubmitionReferenceToWechatThirdPartyPlatformApplications < ActiveRecord::Migration[6.0]
  def change
    add_reference :wechat_third_party_platform_applications, :audit_submition, foreign_key: { to_table: "wechat_third_party_platform_submitions" }, index: { name: "index_wtpp_applications_on_audit_submition_id" }
    add_reference :wechat_third_party_platform_applications, :online_submition, foreign_key: { to_table: "wechat_third_party_platform_submitions" }, index: { name: "index_wtpp_applications_on_online_submition_id" }
    add_reference :wechat_third_party_platform_applications, :trial_submition, foreign_key: { to_table: "wechat_third_party_platform_submitions" }, index: { name: "index_wtpp_applications_on_trial_submition_id" }
  end
end
