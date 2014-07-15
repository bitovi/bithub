class CreateLeaderboardMatview < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE MATERIALIZED VIEW leaderboard AS
 SELECT users.id AS user_id,
    users.name AS user_name,
    users.email AS user_email,
    users.props -> 'avatar_url'::text AS user_gravatar_url,
    ARRAY( SELECT r.name
           FROM user_roles r
           LEFT JOIN users_user_roles ur ON ur.user_role_id = r.id
           WHERE ur.user_id = users.id) AS user_roles,
    ARRAY( SELECT b.name
           FROM public.brands b
           LEFT JOIN public.brands_users bu ON bu.brand_id = b.id
           WHERE bu.user_id = users.id ) AS user_brands,
    users.total_score AS user_score
   FROM users
  ORDER BY users.total_score DESC
WITH DATA;
SQL
  end

  def down
    execute "DROP MATERIALIZED VIEW leaderboard;"
  end
end
