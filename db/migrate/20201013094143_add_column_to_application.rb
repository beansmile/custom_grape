# frozen_string_literal: true

class AddColumnToApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_applications, :mobile, :string
    add_column :bean_applications, :contact, :string
    add_column :bean_applications, :company_name, :string
    add_column :bean_applications, :expired_at, :datetime
  end
end
