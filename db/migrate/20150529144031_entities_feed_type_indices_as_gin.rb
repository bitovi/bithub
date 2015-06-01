class EntitiesFeedTypeIndicesAsGin < ActiveRecord::Migration
  def up
    execute <<-SQL
      drop index entities_feed_name_idx;
      drop index entities_type_name_idx;
      create index entities_feed_name_idx on entities using gin(feed_name);
      create index entities_type_name_idx on entities using gin(type_name);
    SQL
  end
  
  def down
    execute <<-SQL
      drop index entities_feed_name_idx;
      drop index entities_type_name_idx;
      create index entities_feed_name_idx on entities (feed_name);
      create index entities_type_name_idx on entities (type_name);
    SQL
  end
end
