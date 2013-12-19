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

    add_column :events, :type, :string, null: true
    add_column :events, :feed, :string, null: true
    add_column :events, :source_json, :json
    add_column :events, :extracted, :json
    
    rename_column :events, :hash_key, :content_digest
  end

  def down
    # add_column :events, :title, :text
    # add_column :events, :body, :text
    # add_column :events, :url, :text
    # add_column :events, :parent_id, :int
    # add_column :events, :author_id, :int
    # add_column :events, :hash_key, :string

    # remove_column :events, :type
    # remove_column :events, :source_json
  end
end
