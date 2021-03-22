# frozen_string_literal: true

class AddFreightAmountAndFreeFreightAmountToMerchantToBeanMerchants < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_merchants, :freight_amount, :decimal, precision: 10, scale: 2
    add_column :bean_merchants, :free_freight_amount, :decimal, precision: 10, scale: 2
  end
end
