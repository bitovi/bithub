class SetupMaterializedViewsExtension < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS materialized"
  end

  def down
    execute "DROP EXTENSION IF EXISTS materialized"
  end
end
