class AddDefaultValueToOrderRefundAmount < ActiveRecord::Migration[6.0]
  def change
    change_column_default :bean_orders, :promo_total, from: nil, to: 0
    change_column_default :bean_orders, :adjustment_total, from: nil, to: 0
    change_column_default :bean_orders, :refund_amount, from: nil, to: 0
  end
end
