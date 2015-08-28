class AddFkToFilters < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM filters WHERE NOT EXISTS (SELECT 1 FROM embeds WHERE embeds.id = filters.embed_id);
      ALTER TABLE filters DROP CONSTRAINT IF EXISTS fk_filters_to_embeds;
      ALTER TABLE filters ADD CONSTRAINT fk_filters_to_embeds FOREIGN KEY (embed_id) REFERENCES embeds (id) ON DELETE CASCADE;
    SQL
  end

  def drop
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE filters DROP CONSTRAINT IF EXISTS fk_filters_to_embeds;
    SQL
  end
end
