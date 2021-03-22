class UpdatePagesSlugIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :pages, :slug
    add_index :pages, [:slug, :application_id]
  end
end
