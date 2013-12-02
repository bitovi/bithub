class AddTotalScoreToUsers < ActiveRecord::Migration
  def up
    add_column :users, :total_score, :integer, :default => 0

    execute <<-SQL
      CREATE VIEW user_total_score AS
      SELECT users.id AS user_id,
      (
        (SELECT COALESCE(sum(r.authorship_value),0)
        FROM events AS e, rules AS r
        WHERE r.id = e.rule_id
        AND e.author_id = users.id)
        +
        (SELECT COALESCE(sum(u.value),0)
        FROM events AS e, upvotes AS u
        WHERE u.applies_to_id = e.id
        AND e.author_id = users.id)
        +
        (SELECT COALESCE(sum(a.value),0)
        FROM events AS e, awards AS a
        WHERE a.applies_to_id = e.id
        AND e.author_id = users.id)
        +
        (SELECT COALESCE(sum(i.value),0)
        FROM internals AS i
        WHERE i.receiver_id = users.id)
      ) AS score_sum
      FROM users;
    SQL
  end

  def down
    remove_column :users, :total_score

    execute <<-SQL
      DROP VIEW IF EXISTS user_total_score;
    SQL
  end
end
