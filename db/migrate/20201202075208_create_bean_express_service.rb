class CreateBeanExpressService < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_express_services do |t|
      t.string :name
      t.jsonb :configs, default: {}
      t.boolean :is_active, boolean: false
      t.string :type
      t.belongs_to :application, foreign_key: { to_table: :bean_applications }

      t.timestamps
    end
  end
end
