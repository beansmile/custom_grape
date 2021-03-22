# frozen_string_literal: true

class CreateBeanFreightTemplateOnlyProvinces < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_freight_template_only_provinces do |t|
      t.belongs_to :freight_template, null: false, foreign_key: { to_table: "bean_freight_templates" }, index: { name: "index_bftop_ft_id" }
      t.belongs_to :province, null: false, foreign_key: { to_table: "bean_provinces" }

      t.timestamps
    end
  end
end
