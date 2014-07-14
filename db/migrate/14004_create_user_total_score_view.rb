class CreateUserTotalScoreView < ActiveRecord::Migration
  def up
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
  end

  def down
  end
end
