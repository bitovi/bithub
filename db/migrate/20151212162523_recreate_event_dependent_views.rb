class RecreateEventDependentViews < ActiveRecord::Migration
  def up
    execute <<-CACHED_TAG_LIST
      CREATE VIEW entity_aggregated_tag_list AS
      SELECT e.id AS entity_id, string_agg(t.name, ',') AS tag_list
      FROM entities AS e, tags AS t, taggings AS e_t
      WHERE e.id = e_t.taggable_id AND e_t.tag_id = t.id
      GROUP BY e.id;
    CACHED_TAG_LIST

    execute <<-TOTAL_UPVOTES
      CREATE VIEW entity_total_upvotes AS
      SELECT e.id AS entity_id, sum(u.value) AS upvotes_sum
      FROM entities AS e, upvotes AS u
      WHERE e.id = u.applies_to_id
      GROUP BY e.id;
    TOTAL_UPVOTES

    execute <<-TOTAL_SCORE
      CREATE VIEW user_total_score AS
      SELECT users.id AS user_id,
      (
        (SELECT COALESCE(sum(o.value),0)
        FROM entities AS e, ownerships AS o
        WHERE e.id = o.entity_id
        AND o.owner_id = users.id)
        +
        (SELECT COALESCE(sum(u.value),0)
        FROM entities AS e, ownerships AS o, upvotes AS u
        WHERE u.applies_to_id = e.id
        AND e.id = o.entity_id
        AND o.owner_id = users.id)
        +
        (SELECT COALESCE(sum(a.value),0)
        FROM entities AS e, ownerships AS o, awards AS a
        WHERE a.applies_to_id = e.id
        AND e.id = o.entity_id
        AND o.owner_id = users.id)
        +
        (SELECT COALESCE(sum(i.value),0)
        FROM internals AS i
        WHERE i.receiver_id = users.id)
      ) AS score_sum
      FROM users;
    TOTAL_SCORE

    execute <<-PAGINATION
      CREATE MATERIALIZED VIEW pagination AS
        SELECT e.thread_updated_ts AS "ts",
               e.id AS id,
               categories.name AS category,
               ARRAY(
                 SELECT t.name
                   FROM taggings AS tt, tags AS t
                   WHERE tt.taggable_type = 'Event' AND tt.tag_id = t.id AND tt.taggable_id = e.id
               ) AS tags
	      FROM entities AS e
            LEFT JOIN tags AS categories ON e.category_id = categories.id
          WHERE e.parent_id IS NULL
	      ORDER BY e.thread_updated_ts DESC;
    PAGINATION

    execute <<-LEADERBOAD
      CREATE MATERIALIZED VIEW leaderboard AS
      SELECT
        users.id AS user_id,
        users.name AS user_name,
        users.email AS user_email,
        props -> 'avatar_url' AS user_gravatar_url,
        (
          (SELECT coalesce(sum(r.authorship_value),0)
            FROM entities AS e, ownerships AS o, scoring_rules AS r
            WHERE r.id = e.scoring_rule_id
            AND e.id = o.entity_id
            AND o.owner_id = users.id)
          +
          (SELECT coalesce(sum(u.value),0)
            FROM entities AS e, ownerships AS o, upvotes AS u
            WHERE u.applies_to_id = e.id
            AND e.id = o.entity_id
            AND o.owner_id = users.id)
          +
          (SELECT coalesce(sum(a.value),0)
            FROM entities AS e, ownerships AS o, awards AS a
            WHERE a.applies_to_id = e.id
            AND e.id = o.entity_id
            AND o.owner_id = users.id)
          +
          (SELECT coalesce(sum(internals.value),0)
            FROM internals
            WHERE internals.receiver_id = users.id)
        ) AS user_score
      FROM users LEFT JOIN users_roles ON users.id = users_roles.user_id
      WHERE users.name IS NOT NULL
      AND (users_roles.role_id IS NULL OR users_roles.role_id NOT IN (SELECT id FROM roles WHERE name = 'bitovian' OR name = 'admin'))
      ORDER BY user_score desc;
    LEADERBOAD
  end

  def down
  end
end
