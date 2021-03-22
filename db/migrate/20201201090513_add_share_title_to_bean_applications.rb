class AddShareTitleToBeanApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_applications, :share_title, :string
  end
end
