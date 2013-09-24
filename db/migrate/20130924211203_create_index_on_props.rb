class CreateIndexOnProps < ActiveRecord::Migration
  def up
    execute "CREATE INDEX index_events_on_props ON events USING GIST (props);"
  end

  def down
    execute "DROP INDEX IF EXISTS index_events_on_props;"
  end
end
