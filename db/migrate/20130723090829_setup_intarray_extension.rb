class SetupIntarrayExtension < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS intarray"
  end

  def down
    execute "DROP EXTENSION IF EXISTS intarray"
  end
end
