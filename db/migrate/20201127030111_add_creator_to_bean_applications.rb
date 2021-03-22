class AddCreatorToBeanApplications < ActiveRecord::Migration[6.0]
  def change
    add_reference :bean_applications, :creator, foreign_key: { to_table: "admin_users" }
  end
end
