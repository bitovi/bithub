class DropTagsAndTaggings < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute 'DROP VIEW IF EXISTS entity_aggregated_tag_list;'
    ActiveRecord::Base.connection.execute 'DROP TABLE IF EXISTS taggings;'
    ActiveRecord::Base.connection.execute 'DROP TABLE IF EXISTS tags;'
  end
end
