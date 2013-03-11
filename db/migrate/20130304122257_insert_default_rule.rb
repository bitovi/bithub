class InsertDefaultRule < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO rules (required_tags, authorship_value, award_value, upvote_value, created_at, updated_at)
        VALUES ('{}', 0, 0, 1, NOW(), NOW());
      SQL
  end

  def down
    execute <<-SQL
      DELETE FROM rules WHERE required_tags='{}';
    SQL
  end
end
