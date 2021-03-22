# frozen_string_literal: true

class CreateWechatThirdPartyPlatformVisitData < ActiveRecord::Migration[6.0]
  def change
    create_table :wechat_third_party_platform_visit_data do |t|
      t.string :appid
      t.string :ref_date
      t.string :session_cnt
      t.integer :visit_pv, default: 0
      t.integer :visit_uv, default: 0
      t.integer :visit_uv_new, default: 0
      t.string :stay_time_uv
      t.string :stay_time_session
      t.string :visit_depth

      t.timestamps
    end

    add_index :wechat_third_party_platform_visit_data, :appid
  end
end
