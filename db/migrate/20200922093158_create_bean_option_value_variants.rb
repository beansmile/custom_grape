# frozen_string_literal: true

class CreateBeanOptionValueVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_option_value_variants do |t|
      t.belongs_to :variant, null: false, foreign_key: { to_table: "bean_variants" }
      t.belongs_to :option_value, null: false, foreign_key: { to_table: "bean_option_values" }

      t.timestamps
    end
  end
end
