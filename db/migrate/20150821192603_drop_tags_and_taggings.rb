class DropTagsAndTaggings < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute 'DROP VIEW IF EXISTS entity_aggregated_tag_list;'
    drop_table :taggings
    drop_table :tags
  end
end
