# frozen_string_literal: true

class CreateBeanPaymentMethods < ActiveRecord::Migration[6.0]
  def change
    create_table :bean_payment_methods do |t|
      t.string :type
      t.string :name
      t.boolean :active, default: false
      t.jsonb :configuration, default: {}

      t.timestamps
    end
  end
end
