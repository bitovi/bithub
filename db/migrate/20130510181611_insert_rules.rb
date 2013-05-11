class InsertRules < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO rules (required_tags, authorship_value, award_value, upvote_value, created_at, updated_at) VALUES
        ('{article}', 50, 0, 1, NOW(), NOW()),
        ('{twitter}', 0, 0, 1, NOW(), NOW()),
        ('{plugin}', 50, 0, 1, NOW(), NOW()),
        ('{example}', 10, 0, 1, NOW(), NOW()),
        ('{bug}', 50, 100, 1, NOW(), NOW()),
        ('{feature}', 10, 100, 1, NOW(), NOW()),
        ('{app}', 50, 0, 1, NOW(), NOW()),
        ('{code}', 0, 0, 1, NOW(), NOW()),
        ('{comment}', 0, 0, 1, NOW(), NOW()),
        ('{issue_comment_event, bug}', 0, 0, 1, NOW(), NOW()),
        ('{fork_event, digest}', 10, 0, 1, NOW(), NOW()),
        ('{watch_event, digest}', 10, 0, 1, NOW(), NOW()),
        ('{follow_event, twitter}', 0, 0, 1, NOW(), NOW());
      SQL
  end

  def down
    execute <<-SQL
      DELETE FROM rules WHERE required_tags<>'{}';
    SQL
  end
end
