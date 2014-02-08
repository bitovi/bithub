class AlterEvents < ActiveRecord::Migration
  def up
    remove_column :events, :title
    remove_column :events, :body
    remove_column :events, :url
    remove_column :events, :parent_id
    remove_column :events, :author_id
    remove_column :events, :category_id
    remove_column :events, :feed_id
    remove_column :events, :rule_id
    remove_column :events, :cached_tag_list
    remove_column :events, :image
    remove_column :events, :thread_updated_at
    remove_column :events, :thread_updated_date
    remove_column :events, :total_upvotes
    remove_column :events, :origin_date
    remove_column :events, :origin_ts

    add_column :events, :type_name, :string, null: true
    add_column :events, :feed_name, :string, null: true
    add_column :events, :source_json, :json
    
    rename_column :events, :hash_key, :content_digest
  end

  def down
  end
end
