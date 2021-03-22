class AddProductNameAndOptionTypesToBeanLineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_line_items, :product_name, :string
    add_column :bean_line_items, :option_types, :jsonb, default: []
  end
end
