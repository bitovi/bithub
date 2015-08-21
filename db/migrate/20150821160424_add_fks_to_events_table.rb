class AddFksToEventsTable < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM events WHERE NOT EXISTS (SELECT 1 FROM entities WHERE entities.id = events.entity_id);
      ALTER TABLE events DROP CONSTRAINT IF EXISTS fk_events_to_entities;
      ALTER TABLE events ADD CONSTRAINT fk_events_to_entities FOREIGN KEY (entity_id) REFERENCES entities (id) ON DELETE CASCADE;
    SQL
  end

  def drop
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE events DROP CONSTRAINT IF EXISTS fk_events_to_entities;
    SQL
  end
end
