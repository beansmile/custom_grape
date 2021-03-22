# frozen_string_literal: true

class CreateWechatThirdPartyPlatformRegisters < ActiveRecord::Migration[6.0]
  def change
    create_table :wechat_third_party_platform_registers do |t|
      t.string :name
      t.string :code
      t.string :code_type
      t.string :legal_persona_wechat
      t.string :legal_persona_name
      t.string :component_phone
      t.jsonb :audit_result, default: {}
      t.integer :state, default: 0
      t.belongs_to :creator
      t.belongs_to :application

      t.timestamps
    end
  end
end
