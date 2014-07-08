class CreateLeaderboardMatview < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE MATERIALIZED VIEW leaderboard
AS
SELECT users.id AS user_id,
    users.name AS user_name,
    users.email AS user_email,
    users.props -> 'avatar_url'::text AS user_gravatar_url,
    ARRAY( SELECT r.name
	    FROM roles r
	    LEFT JOIN users_roles ur ON ur.role_id = r.id
	    WHERE ur.user_id = users.id ) AS user_roles,
    (( SELECT COALESCE(sum(r.authorship_value), 0::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            scoring_rules r
          WHERE r.id = e.scoring_rule_id AND e.id = o.entity_id AND o.owner_id = users.id)) + (( SELECT COALESCE(sum(u.value), 0::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            upvotes u
          WHERE u.applies_to_id = e.id AND e.id = o.entity_id AND o.owner_id = users.id)) + (( SELECT COALESCE(sum(a.value), 0::bigint) AS "coalesce"
           FROM entities e,
            ownerships o,
            awards a
          WHERE a.applies_to_id = e.id AND e.id = o.entity_id AND o.owner_id = users.id)) + (( SELECT COALESCE(sum(internals.value), 0::bigint) AS "coalesce"
           FROM internals
          WHERE internals.receiver_id = users.id)) AS user_score
   FROM users
  WHERE users.name IS NOT NULL
  ORDER BY (( SELECT COALESCE(sum(r.authorship_value), 0::bigint) AS "coalesce"
      FROM entities e,
       ownerships o,
       scoring_rules r
     WHERE r.id = e.scoring_rule_id AND e.id = o.entity_id AND o.owner_id = users.id)) + (( SELECT COALESCE(sum(u.value), 0::bigint) AS "coalesce"
      FROM entities e,
       ownerships o,
       upvotes u
     WHERE u.applies_to_id = e.id AND e.id = o.entity_id AND o.owner_id = users.id)) + (( SELECT COALESCE(sum(a.value), 0::bigint) AS "coalesce"
      FROM entities e,
       ownerships o,
       awards a
     WHERE a.applies_to_id = e.id AND e.id = o.entity_id AND o.owner_id = users.id)) + (( SELECT COALESCE(sum(internals.value), 0::bigint) AS "coalesce"
      FROM internals
     WHERE internals.receiver_id = users.id)) DESC
WITH DATA;
SQL
  end

  def down
    execute "DROP MATERIALIZED VIEW leaderboard;"
  end
end
