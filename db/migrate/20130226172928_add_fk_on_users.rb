class AddFkOnUsers < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE users 
        ADD CONSTRAINT fk_users_countries
        FOREIGN KEY (country_id) 
        REFERENCES countries(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE users 
        DROP CONSTRAINT fk_users_countries
    SQL
  end
end
