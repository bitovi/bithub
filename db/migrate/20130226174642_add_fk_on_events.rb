class AddFkOnEvents < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE events 
        ADD CONSTRAINT fk_events_users
        FOREIGN KEY (author_id) 
        REFERENCES users(id)
    SQL
    execute <<-SQL
      ALTER TABLE events 
        ADD CONSTRAINT fk_events_rules
        FOREIGN KEY (rule_id) 
        REFERENCES rules(id)
    SQL
    execute <<-SQL
      ALTER TABLE events 
        ADD CONSTRAINT fk_events_feed_tags
        FOREIGN KEY (feed_id) 
        REFERENCES tags(id)
    SQL
    execute <<-SQL
      ALTER TABLE events 
        ADD CONSTRAINT fk_events_category_tags
        FOREIGN KEY (category_id) 
        REFERENCES tags(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE events 
        DROP CONSTRAINT fk_events_users
    SQL
    execute <<-SQL
      ALTER TABLE events 
        DROP CONSTRAINT fk_events_rules
    SQL
    execute <<-SQL
      ALTER TABLE events 
        DROP CONSTRAINT fk_events_feed_tags
    SQL
    execute <<-SQL
      ALTER TABLE events 
        DROP CONSTRAINT fk_events_category_tags
    SQL
  end
end
