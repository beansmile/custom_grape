# frozen_string_literal: true

class CreateBeanCalculators < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_calculators do |t|
      t.string :type
      t.jsonb :preferences, default: {}
      t.references :calculable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
