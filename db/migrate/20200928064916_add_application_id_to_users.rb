# frozen_string_literal: true

class AddApplicationIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :application, foreign_key: { to_table: "bean_applications" }
  end
end
