class AddFkOnEvents < ActiveRecord::Migration
  def up
    execute "ALTER TABLE events ADD CONSTRAINT fk_events_users FOREIGN KEY (author_id) REFERENCES users(id);"
    execute "ALTER TABLE events ADD CONSTRAINT fk_events_rules FOREIGN KEY (rule_id) REFERENCES rules(id);"
    execute "ALTER TABLE events ADD CONSTRAINT fk_events_feed_tags FOREIGN KEY (feed_id) REFERENCES tags(id);"
    execute "ALTER TABLE events ADD CONSTRAINT fk_events_category_tags FOREIGN KEY (category_id) REFERENCES tags(id);"
  end

  def down
    execute "ALTER TABLE events DROP CONSTRAINT fk_events_users;"
    execute "ALTER TABLE events DROP CONSTRAINT fk_events_rules;"
    execute "ALTER TABLE events DROP CONSTRAINT fk_events_feed_tags;"
    execute "ALTER TABLE events DROP CONSTRAINT fk_events_category_tags;"
  end
end
