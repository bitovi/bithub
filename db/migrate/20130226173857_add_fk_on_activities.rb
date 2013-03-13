class AddFkOnActivities < ActiveRecord::Migration
  def up

    # upvotes
    execute <<-SQL
      ALTER TABLE upvotes 
        ADD CONSTRAINT fk_upvotes_events
        FOREIGN KEY (applies_to_id) 
        REFERENCES events(id)
    SQL
    execute <<-SQL
      ALTER TABLE upvotes 
        ADD CONSTRAINT fk_upvotes_users
        FOREIGN KEY (actor_id) 
        REFERENCES users(id)
    SQL

    # stakes
    execute <<-SQL
      ALTER TABLE stakes 
        ADD CONSTRAINT fk_stakes_events
        FOREIGN KEY (applies_to_id) 
        REFERENCES events(id)
    SQL
    execute <<-SQL
      ALTER TABLE stakes 
        ADD CONSTRAINT fk_stakes_users
        FOREIGN KEY (actor_id) 
        REFERENCES users(id)
    SQL

    # awards
    execute <<-SQL
      ALTER TABLE awards 
        ADD CONSTRAINT fk_awards_events
        FOREIGN KEY (applies_to_id) 
        REFERENCES events(id)
    SQL
    execute <<-SQL
      ALTER TABLE awards 
        ADD CONSTRAINT fk_awards_users
        FOREIGN KEY (actor_id) 
        REFERENCES users(id)
    SQL

    # internal
    execute <<-SQL
      ALTER TABLE internal 
        ADD CONSTRAINT fk_internal_actor_users
        FOREIGN KEY (actor_id) 
        REFERENCES users(id)
    SQL
    execute <<-SQL
      ALTER TABLE internal 
        ADD CONSTRAINT fk_internal_receiver_users
        FOREIGN KEY (receiver_id) 
        REFERENCES users(id)
    SQL
  end

  def down

    # upvotes
    execute <<-SQL
      ALTER TABLE upvotes 
        DROP CONSTRAINT fk_upvotes_events
    SQL
    execute <<-SQL
      ALTER TABLE upvotes 
        DROP CONSTRAINT fk_upvotes_users
    SQL

    # stakes
    execute <<-SQL
      ALTER TABLE stakes 
        DROP CONSTRAINT fk_stakes_events
    SQL
    execute <<-SQL
      ALTER TABLE stakes 
        DROP CONSTRAINT fk_stakes_users
    SQL

    # awards
    execute <<-SQL
      ALTER TABLE awards 
        DROP CONSTRAINT fk_awards_events
    SQL
    execute <<-SQL
      ALTER TABLE awards 
        DROP CONSTRAINT fk_awards_users
    SQL

    # internal
    execute <<-SQL
      ALTER TABLE internal 
        DROP CONSTRAINT fk_internal_actor_users
    SQL
    execute <<-SQL
      ALTER TABLE internal 
        DROP CONSTRAINT fk_internal_receiver_users
    SQL
  end
end
