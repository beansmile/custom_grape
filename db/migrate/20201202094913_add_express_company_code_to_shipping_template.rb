class AddExpressCompanyCodeToShippingTemplate < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_shipping_categories, :company_code, :string
  end
end
