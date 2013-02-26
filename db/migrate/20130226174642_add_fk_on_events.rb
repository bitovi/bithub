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
        ADD CONSTRAINT fk_events_categories
        FOREIGN KEY (category_id) 
        REFERENCES categories(id)
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
        DROP CONSTRAINT fk_events_categories
    SQL
  end
end
