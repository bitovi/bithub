class AddFkToEmbedPresets < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM embed_presets WHERE NOT EXISTS (SELECT 1 FROM embeds WHERE embeds.id = embed_presets.embed_id);
      ALTER TABLE embed_presets DROP CONSTRAINT IF EXISTS fk_embed_presets_to_embeds;
      ALTER TABLE embed_presets ADD CONSTRAINT fk_embed_presets_to_embeds FOREIGN KEY (embed_id) REFERENCES embeds (id) ON DELETE CASCADE;
    SQL
  end

  def drop
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE embed_presets DROP CONSTRAINT IF EXISTS fk_embed_presets_to_embeds;
    SQL
  end
end
