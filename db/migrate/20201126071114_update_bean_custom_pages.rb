class UpdateBeanCustomPages < ActiveRecord::Migration[6.0]
  def change
    rename_column :bean_custom_pages, :name, :title
    rename_column :bean_custom_pages, :en_name, :slug
    add_belongs_to :bean_custom_pages, :draft_custom_page, foreign_key: { to_table: "bean_custom_pages" }
    add_column :bean_custom_pages, :latest_sync_time, :datetime
    add_column :bean_custom_pages, :configs, :jsonb, default: {}
  end
end
