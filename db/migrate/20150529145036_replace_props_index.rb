class ReplacePropsIndex < ActiveRecord::Migration
  def up
    execute <<-SQL
      drop index entities_props_idx;
      drop index entities_props_retweeted_id_idx;
      
      create index entities_props_retweeted_id_idx on entities ((entities.props->'retweeted_id')) where (entities.props ? 'retweeted_id');
      create index entities_props_target_id_idx on entities ((entities.props->'target_id')) where (entities.props ? 'target_id');
      create index entities_props_repo_name_idx on entities ((entities.props->'repo_name')) where (entities.props ? 'repo_name');
      create index entities_props_event_id_idx on entities ((entities.props->'event_id')) where (entities.props ? 'event_id');
    SQL
  end
  
  def down
    execute <<-SQL
      drop index entities_props_retweeted_id_idx;
      drop index entities_props_target_id_idx;
      drop index entities_props_repo_name_idx;
      drop index entities_props_event_id_idx;

      create index entities_props_idx on entities using btree(props);
      create index entities_props_retweeted_id_idx on entities using btree((props->'retweeted_id'));
    SQL
  end
end
