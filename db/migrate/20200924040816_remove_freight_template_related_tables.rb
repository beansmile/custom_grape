# frozen_string_literal: true

class RemoveFreightTemplateRelatedTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :bean_freight_template_only_provinces do |t|
      t.belongs_to :freight_template, null: false, foreign_key: { to_table: "bean_freight_templates" }, index: { name: "index_bftop_ft_id" }
      t.belongs_to :province, null: false, foreign_key: { to_table: "bean_provinces" }

      t.timestamps
    end

    drop_table :bean_freight_template_except_provinces do |t|
      t.belongs_to :freight_template, null: false, foreign_key: { to_table: "bean_freight_templates" }, index: { name: "index_bftep_ft_id" }
      t.belongs_to :province, null: false, foreign_key: { to_table: "bean_provinces" }

      t.timestamps
    end

    drop_table :bean_freight_templates do |t|
      t.string :name
      t.belongs_to :country, foreign_key: { to_table: :bean_countries }
      t.belongs_to :store, null: false, foreign_key: { to_table: "bean_stores"}

      t.timestamps
    end
  end
end
