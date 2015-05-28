class BuildEntitiesIndices < ActiveRecord::Migration
  def up
    execute <<-SQL
      create index entities_feed_name_idx on entities (feed_name);
      create index entities_type_name_idx on entities (type_name);
      create index entities_origin_id_idx on entities (origin_id);
      create index entities_props_idx on entities using btree(props);
    SQL
  end

  def down
    execute <<-SQL
      drop index entities_feed_name_idx;
      drop index entities_type_name_idx;
      drop index entities_origin_id_idx;
      drop index entities_props_idx;
    SQL
  end
end
