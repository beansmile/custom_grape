# frozen_string_literal: true

class CreateBeanZoneMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_zone_members do |t|
      t.belongs_to :zone, null: false, foreign_key: { to_table: "bean_zones" }
      t.references :zoneable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
