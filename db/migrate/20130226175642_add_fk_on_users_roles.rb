class AddFkOnEvents < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE users_roles
        ADD CONSTRAINT fk_users_roles_to_users
        FOREIGN KEY (user_id) 
        REFERENCES users(id)
    SQL
    execute <<-SQL
      ALTER TABLE users_roles
        ADD CONSTRAINT fk_users_roles_to_roles
        FOREIGN KEY (role_id) 
        REFERENCES roles(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE users_roles
        DROP CONSTRAINT fk_users_roles_to_users
    SQL
    execute <<-SQL
      ALTER TABLE users_roles
        DROP CONSTRAINT fk_users_roles_to_roles
    SQL
  end
end
