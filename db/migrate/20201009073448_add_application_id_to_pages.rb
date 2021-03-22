# frozen_string_literal: true

class AddApplicationIdToPages < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :pages, :application, foreign_key: { to_table: "bean_applications" }
  end
end
