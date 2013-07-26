class SetupIntarray < ActiveRecord::Migration
  def self.up
    execute "CREATE EXTENSION IF NOT EXISTS intarray"
  end

  def self.down
    execute "DROP EXTENSION IF EXISTS intarray"
  end
end
