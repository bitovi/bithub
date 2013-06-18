class AddExplicitUniqueConstraintToEventsHashKey < ActiveRecord::Migration
  def up
    execute "CREATE UNIQUE INDEX unique_hash_key ON events (hash_key);"
  end

  def down
    execute "DROP INDEX IF EXISTS unique_hash_key;"
  end
end
