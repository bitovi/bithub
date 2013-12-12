class DropEventDependentFks < ActiveRecord::Migration
  def up
    execute "ALTER TABLE upvotes DROP CONSTRAINT fk_upvotes_events;"
    execute "ALTER TABLE anteups DROP CONSTRAINT fk_anteups_events;"
    execute "ALTER TABLE awards DROP CONSTRAINT fk_awards_events;"
    execute "ALTER TABLE events DROP CONSTRAINT fk_events_users;"
    execute "ALTER TABLE events DROP CONSTRAINT fk_events_rules;"
    execute "ALTER TABLE events DROP CONSTRAINT fk_events_feed_tags;"
    execute "ALTER TABLE events DROP CONSTRAINT fk_events_category_tags;"
  end
  
  def down
  end
end
