class AddApiclientCertToPaymentMethod < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_payment_methods, :apiclient_cert, :string
  end
end
