class RecreateEventDependentViews < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW entity_aggregated_tag_list AS
      SELECT e.id AS entity_id, string_agg(t.name, ',') AS tag_list
      FROM entities AS e, tags AS t, taggings AS e_t
      WHERE e.id = e_t.taggable_id AND e_t.tag_id = t.id
      GROUP BY e.id;
    SQL
    
    execute <<-SQL
      CREATE VIEW entity_total_upvotes AS
      SELECT e.id AS entity_id, sum(u.value) AS upvotes_sum
      FROM entities AS e, upvotes AS u
      WHERE e.id = u.applies_to_id
      GROUP BY e.id;
    SQL
    
    execute <<-SQL
      CREATE VIEW user_total_score AS
      SELECT users.id AS user_id,
      (
        (SELECT COALESCE(sum(r.authorship_value),0)
        FROM entities AS e, rules AS r
        WHERE r.id = e.rule_id
        AND e.author_id = users.id)
        +
        (SELECT COALESCE(sum(u.value),0)
        FROM entities AS e, upvotes AS u
        WHERE u.applies_to_id = e.id
        AND e.author_id = users.id)
        +
        (SELECT COALESCE(sum(a.value),0)
        FROM entities AS e, awards AS a
        WHERE a.applies_to_id = e.id
        AND e.author_id = users.id)
        +
        (SELECT COALESCE(sum(i.value),0)
        FROM internals AS i
        WHERE i.receiver_id = users.id)
      ) AS score_sum
      FROM users;
    SQL

    execute <<-SQL
      CREATE MATERIALIZED VIEW pagination AS
      SELECT
        e.origin_ts::date AS origin_date,
        t.name::text AS category,
        count (*) AS cnt
      FROM tags AS t,taggings AS tt, tags AS mt, entities AS e, taggings AS et
      WHERE tt.tag_id = mt.id
      AND tt.taggable_id = t.id
      AND tt.taggable_type = 'ActsAsTaggableOn::Tag'
      AND et.tag_id = t.id
      AND et.taggable_id = e.id
      AND et.taggable_type = 'Entity'
      AND mt.name = 'categories'
      GROUP BY origin_date, category 
      ORDER BY origin_date desc;
    SQL
    
    execute <<-SQL
      CREATE MATERIALIZED VIEW LEADERBOARD AS
      SELECT
        users.id AS user_id,
        users.name AS user_name,
        users.email AS user_email,
        props -> 'avatar_url' AS user_gravatar_url,
        (
          (SELECT coalesce(sum(rules.authorship_value),0)
            FROM entities, rules
            WHERE rules.id = entities.rule_id
            AND entities.author_id = users.id)
          +
          (SELECT coalesce(sum(upvotes.value),0)
            FROM entities, upvotes
            WHERE upvotes.applies_to_id = entities.id
            AND entities.author_id = users.id)
          +
          (SELECT coalesce(sum(awards.value),0)
            FROM entities, awards
            WHERE awards.applies_to_id = entities.id
            AND entities.author_id = users.id)
          +
          (SELECT coalesce(sum(internals.value),0)
            FROM internals
            WHERE internals.receiver_id = users.id)
          -
          (SELECT coalesce(sum(anteups.value),0)
            FROM anteups
            WHERE anteups.actor_id = users.id
            AND anteups.fullfilled = true)
        ) AS user_score
      FROM users LEFT JOIN users_roles ON users.id = users_roles.user_id
      WHERE name IS NOT NULL
      AND role_id IS NULL
      OR role_id NOT IN (SELECT id FROM roles WHERE name = 'bitovian' OR name = 'admin')
      ORDER BY user_score desc;
    SQL
  end

  def down
  end
end
