class AddShareTitleToBeanProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_products, :share_title, :string
  end
end
