class AddFkOnActivities < ActiveRecord::Migration
  def up
    execute "ALTER TABLE upvotes ADD CONSTRAINT fk_upvotes_events FOREIGN KEY (applies_to_id) REFERENCES events(id);"
    execute "ALTER TABLE upvotes ADD CONSTRAINT fk_upvotes_users FOREIGN KEY (actor_id) REFERENCES users(id);"
    execute "ALTER TABLE anteups ADD CONSTRAINT fk_anteups_events FOREIGN KEY (applies_to_id) REFERENCES events(id);"
    execute "ALTER TABLE anteups ADD CONSTRAINT fk_anteups_users FOREIGN KEY (actor_id) REFERENCES users(id);"
    execute "ALTER TABLE awards ADD CONSTRAINT fk_awards_events FOREIGN KEY (applies_to_id) REFERENCES events(id);"
    execute "ALTER TABLE awards ADD CONSTRAINT fk_awards_users FOREIGN KEY (actor_id) REFERENCES users(id);"
    execute "ALTER TABLE internals ADD CONSTRAINT fk_internals_actor_users FOREIGN KEY (actor_id) REFERENCES users(id);"
    execute "ALTER TABLE internals ADD CONSTRAINT fk_internals_receiver_users FOREIGN KEY (receiver_id) REFERENCES users(id);"
  end

  def down
    execute "ALTER TABLE upvotes DROP CONSTRAINT fk_upvotes_events;"
    execute "ALTER TABLE upvotes DROP CONSTRAINT fk_upvotes_users;"
    execute "ALTER TABLE anteups DROP CONSTRAINT fk_anteups_events;"
    execute "ALTER TABLE anteups DROP CONSTRAINT fk_anteups_users;"
    execute "ALTER TABLE awards DROP CONSTRAINT fk_awards_events;"
    execute "ALTER TABLE awards DROP CONSTRAINT fk_awards_users;"
    execute "ALTER TABLE internals DROP CONSTRAINT fk_internals_actor_users;"
    execute "ALTER TABLE internals DROP CONSTRAINT fk_internals_receiver_users;"
  end
end
