class InitialSetup < ActiveRecord::Migration
  def up
    unless ENV['VAGRANT'].present?
      execute "CREATE EXTENSION IF NOT EXISTS hstore"
      execute "CREATE EXTENSION IF NOT EXISTS intarray"
    end
  end

  def down
    unless ENV['VAGRANT'].present?
      execute "DROP EXTENSION IF EXISTS hstore"
      execute "DROP EXTENSION IF EXISTS intarray"
    end
  end
end
