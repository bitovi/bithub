class AddFkOnEventsCategories < ActiveRecord::Migration
  def up
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
        DROP CONSTRAINT fk_events_categories
    SQL
  end
end
