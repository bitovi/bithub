class AddIndexToEntityIdOnEvents < ActiveRecord::Migration
  def change
    execute <<-SQL
      create index events_entity_id_idx on events (entity_id);
    SQL
  end
end
