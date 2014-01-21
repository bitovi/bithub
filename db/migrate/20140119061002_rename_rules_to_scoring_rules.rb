class RenameRulesToScoringRules < ActiveRecord::Migration
  def up
    rename_table :rules, :scoring_rules
    rename_column :entities, :rule_id, :scoring_rule_id

    execute <<-CONSTRAINTS
      ALTER TABLE entities DROP CONSTRAINT fk_entities_rules;
      ALTER TABLE entities ADD CONSTRAINT fk_entities_scoring_rules FOREIGN KEY (scoring_rule_id) REFERENCES scoring_rules(id);
    CONSTRAINTS
    
    execute <<-LEADERBOAD
      DROP MATERIALIZED VIEW LEADERBOARD;
      CREATE MATERIALIZED VIEW LEADERBOARD AS
      SELECT
        users.id AS user_id,
        users.name AS user_name,
        users.email AS user_email,
        props -> 'avatar_url' AS user_gravatar_url,
        (
          (SELECT coalesce(sum(scoring_rules.authorship_value),0)
            FROM entities, scoring_rules
            WHERE scoring_rules.id = entities.scoring_rule_id
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
    LEADERBOAD

  end

  def down
    rename_table :scoring_rules, :rules
    rename_column :entities, :scoring_rule_id, :rule_id
  end
end
