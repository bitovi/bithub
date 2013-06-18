class RemoveNonUniqueHashKeyIndexFromEvents < ActiveRecord::Migration
  def up
    execute "DROP INDEX IF EXISTS index_events_on_hash_key;"
  end

  def down
    execute "CREATE INDEX index_events_on_hash_key ON events (hash_key);"
  end
end
