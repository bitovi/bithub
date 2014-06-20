class CreateLeaderboardMatview < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE MATERIALIZED VIEW leaderboard AS
  SELECT id AS user_id,
         name AS user_name,
         email AS user_email,
         props -> 'avatar_url'::text AS user_gravatar_url,
         ARRAY( SELECT r.name FROM user_roles r LEFT JOIN users_user_roles ur ON ur.user_role_id = r.id WHERE ur.user_id = users.id) AS user_roles,
         total_score AS user_score
    FROM users ORDER BY total_score DESC;
    SQL

    execute <<-SQL
REFRESH MATERIALIZED VIEW leaderboard;
    SQL
  end

  def down
    execute "DROP MATERIALIZED VIEW leaderboard;"
  end
end
