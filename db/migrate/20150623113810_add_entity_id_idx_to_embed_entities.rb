class AddEntityIdIdxToEmbedEntities < ActiveRecord::Migration
  def up
    execute "create index embed_entities_entity_id_idx on embed_entities (entity_id);"
  end

  def down
    execute "drop index embed_entities_entity_id_idx;"
  end
end
