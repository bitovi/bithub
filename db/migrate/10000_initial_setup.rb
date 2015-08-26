class InitialSetup < ActiveRecord::Migration
  def change
    if ENV['VAGRANT'].nil?
      ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS hstore WITH VERSION '1.2';"
      ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS intarray WITH VERSION '1.0'"
      ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS btree_gin"
      ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS plpgsql;"
    end

    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS hstore;"
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS intarray;"
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS btree_gin"
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS plpgsql;"
  end
end
