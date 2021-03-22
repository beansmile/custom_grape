class AddBindedProjectApplicationIdToWtppApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :wechat_third_party_platform_applications, :binded_project_application_id, :integer
  end
end
