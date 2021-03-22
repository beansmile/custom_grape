class AddHotwordsToApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :bean_applications, :hotwords, :string, default: [], array: true
  end
end
