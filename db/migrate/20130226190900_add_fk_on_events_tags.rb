class AddFkOnEventsTags < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE events_tags
        ADD CONSTRAINT fk_events_tags_tag
        FOREIGN KEY (tag_id) 
        REFERENCES tags(id)
    SQL
    execute <<-SQL
      ALTER TABLE events_tags 
        ADD CONSTRAINT fk_events_tags_event
        FOREIGN KEY (event_id) 
        REFERENCES events(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE events_tags
        DROP CONSTRAINT fk_events_tags_tag
    SQL
    execute <<-SQL
      ALTER TABLE events_tags
        DROP CONSTRAINT fk_events_tags_event
    SQL
  end
end
