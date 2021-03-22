# frozen_string_literal: true

class AddConstraintToBeanStockLocationItems < ActiveRecord::Migration[6.0]
  def up
    execute "ALTER TABLE bean_stock_location_items ADD CONSTRAINT valid_count_on_hand CHECK (count_on_hand >= 0)"
  end

  def down
    execute "ALTER TABLE bean_stock_location_items DROP CONSTRAINT valid_count_on_hand"
  end
end
