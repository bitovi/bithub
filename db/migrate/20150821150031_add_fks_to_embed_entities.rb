class AddFksToEmbedEntities < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM embed_entities
      WHERE NOT EXISTS (SELECT 1 FROM entities WHERE entities.id = embed_entities.entity_id);

      DELETE FROM embed_entities
      WHERE NOT EXISTS (SELECT 1 FROM embeds WHERE embeds.id = embed_entities.embed_id);

      ALTER TABLE embed_entities DROP CONSTRAINT IF EXISTS fk_embed_entities_to_entities;
      ALTER TABLE embed_entities DROP CONSTRAINT IF EXISTS fk_embed_entities_to_embeds;

      ALTER TABLE embed_entities
      ADD CONSTRAINT fk_embed_entities_to_entities
      FOREIGN KEY (entity_id) REFERENCES entities (id)
      ON DELETE CASCADE;

      ALTER TABLE embed_entities
      ADD CONSTRAINT fk_embed_entities_to_embeds
      FOREIGN KEY (embed_id) REFERENCES embeds (id)
      ON DELETE CASCADE;
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE embed_entities DROP CONSTRAINT IF EXISTS fk_embed_entities_to_entities;
      ALTER TABLE embed_entities DROP CONSTRAINT IF EXISTS fk_embed_entities_to_embeds;
    SQL
  end
end
