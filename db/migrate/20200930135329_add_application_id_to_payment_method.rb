# frozen_string_literal: true

class AddApplicationIdToPaymentMethod < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :bean_payment_methods, :application, foreign_key: { to_table: :bean_applications }
  end
end
