class AddConstraintsOnAchievements < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE achievements
        ADD CONSTRAINT fk_users_rewards_users
        FOREIGN KEY (user_id)
        REFERENCES users(id)
    SQL

    execute <<-SQL
      ALTER TABLE achievements
        ADD CONSTRAINT fk_users_rewards_rewards
        FOREIGN KEY (reward_id)
        REFERENCES rewards(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE achievements
        DROP CONSTRAINT fk_users_rewards_users
    SQL
    execute <<-SQL
      ALTER TABLE achievements
        DROP CONSTRAINT fk_users_rewards_rewards
    SQL
  end
end
