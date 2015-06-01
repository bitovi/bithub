class BuildIndexOnEntitiesPropsRetweetId < ActiveRecord::Migration
  def up
    execute <<-SQL
      create index entities_props_retweeted_id_idx on entities using btree((props->'retweeted_id'));
    SQL
  end
  
  def down
    execute <<-SQL
      drop index entities_props_retweeted_id_idx;
    SQL
  end
end
