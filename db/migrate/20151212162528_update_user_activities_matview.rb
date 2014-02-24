class UpdateUserActivitiesMatview < ActiveRecord::Migration
  def up
    execute <<-SQL
DROP MATERIALIZED VIEW IF EXISTS user_activities;

CREATE MATERIALIZED VIEW user_activities AS
SELECT 'Entity' AS model_name, entities.id AS id, ownerships.owner_id AS user_id, ownerships.ownership_type AS ownership_type, entities.title AS title, total_upvotes + scoring_rules.authorship_value AS value, entities.origin_ts AS ts, entities.cached_tag_list AS tags
	FROM entities
		JOIN ownerships ON ownerships.entity_id = entities.id
		JOIN scoring_rules ON scoring_rules.id = entities.scoring_rule_id
UNION
SELECT 'Internal' AS model_name, internals.id AS id, internals.receiver_id AS user_id, NULL AS ownership_type, internals.comment AS title, internals.value AS value, internals.created_at AS ts, '' AS tags
	FROM internals
UNION
SELECT 'Anteup' AS model_name, anteups.id AS id, anteups.actor_id AS user_id, NULL AS ownership_type, '' AS title, anteups.value AS value, anteups.created_at AS ts, '' AS tags
	FROM anteups
UNION
SELECT 'Upvote' AS model_name, upvotes.id AS id, upvotes.actor_id AS user_id, NULL AS ownership_type, entities.title AS title, 0 AS value, upvotes.created_at AS ts, '' AS tags
	FROM upvotes
		JOIN entities ON upvotes.applies_to_id = entities.id
SQL
  end

  def down
    execute <<-SQL
DROP MATERIALIZED VIEW IF EXISTS user_activities;
SQL
  end
end
