class RemoveComponentsFromBeanCustomPages < ActiveRecord::Migration[6.0]
  def change
    remove_column :bean_custom_pages, :components, :jsonb, default: []
  end
end
