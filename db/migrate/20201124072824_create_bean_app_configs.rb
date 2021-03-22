class CreateBeanAppConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_app_configs do |t|
      t.jsonb :ext_json, default: {}
      t.belongs_to :application, foreign_key: { to_table: "bean_applications" }

      t.timestamps
    end
  end
end
