class AddApplicationIdToTagsAndBlob < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_blobs, :application_id, :integer
    add_index :active_storage_blobs, :application_id

    add_column :taggings, :application_id, :integer
    add_index :taggings, :application_id
  end
end
