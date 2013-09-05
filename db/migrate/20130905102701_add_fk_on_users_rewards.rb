class AddFkOnUsersRewards < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE users_rewards 
        ADD CONSTRAINT fk_users_rewards_users
        FOREIGN KEY (user_id) 
        REFERENCES users(id)
    SQL

    execute <<-SQL
      ALTER TABLE users_rewards 
        ADD CONSTRAINT fk_users_rewards_rewards
        FOREIGN KEY (reward_id) 
        REFERENCES rewards(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE users_rewards
        DROP CONSTRAINT fk_users_rewards_users
    SQL
    execute <<-SQL
      ALTER TABLE users_rewards
        DROP CONSTRAINT fk_users_rewards_rewards
    SQL
  end
end
