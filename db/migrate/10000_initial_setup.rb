class InitialSetup < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS hstore;"
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS intarray;"
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS btree_gin"
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS plpgsql;"
  end
end
