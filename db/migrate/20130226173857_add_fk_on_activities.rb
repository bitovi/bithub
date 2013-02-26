class AddFkOnActivities < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE activities 
        ADD CONSTRAINT fk_activities_events
        FOREIGN KEY (applies_to_event_id) 
        REFERENCES events(id)
    SQL
    execute <<-SQL
      ALTER TABLE activities 
        ADD CONSTRAINT fk_activities_users
        FOREIGN KEY (actor_id) 
        REFERENCES users(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE activities 
        DROP CONSTRAINT fk_activities_events
    SQL
    execute <<-SQL
      ALTER TABLE activities 
        DROP CONSTRAINT fk_activities_users
    SQL
  end
end
