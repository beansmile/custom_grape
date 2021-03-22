# frozen_string_literal: true

class AddMerchantToBeanOptionTypes < ActiveRecord::Migration[6.0]
  def change
    add_reference :bean_option_types, :merchant, foreign_key: { to_table: "bean_merchants" }
  end
end
