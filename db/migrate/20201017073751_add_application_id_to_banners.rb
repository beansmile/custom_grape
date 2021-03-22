# frozen_string_literal: true

class AddApplicationIdToBanners < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :banners, :application, foreign_key: { to_table: :bean_applications }
  end
end
