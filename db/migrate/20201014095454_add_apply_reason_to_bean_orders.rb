# frozen_string_literal: true

class AddApplyReasonToBeanOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_orders, :apply_reason, :string
  end
end
