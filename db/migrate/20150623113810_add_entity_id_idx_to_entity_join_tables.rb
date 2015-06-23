class AddEntityIdIdxToEntityJoinTables < ActiveRecord::Migration
  def up
    execute <<-SQL
      create index embed_entities_entity_id_idx on embed_entities (entity_id);
      create index service_entities_entity_id_idx on service_entities (entity_id);
    SQL
  end

  def down
    execute <<-SQL
      drop index embed_entities_entity_id_idx;
      drop index service_entities_entity_id_idx;
    SQL
  end
end
