class AddFkOnUsers < ActiveRecord::Migration
  def up
    execute "ALTER TABLE users ADD CONSTRAINT fk_users_countries FOREIGN KEY (country_id) REFERENCES countries(id);"
  end

  def down
    execute "ALTER TABLE users DROP CONSTRAINT fk_users_countries;"
  end
end
