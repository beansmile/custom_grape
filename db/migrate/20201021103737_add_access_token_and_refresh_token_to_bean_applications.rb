# frozen_string_literal: true

class AddAccessTokenAndRefreshTokenToBeanApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_applications, :access_token, :string
    add_column :bean_applications, :refresh_token, :string
    add_column :bean_applications, :func_info, :jsonb, default: []
  end
end
