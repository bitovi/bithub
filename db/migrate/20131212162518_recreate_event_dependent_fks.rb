class RecreateEventDependentFks < ActiveRecord::Migration
  def up
    execute "ALTER TABLE upvotes ADD CONSTRAINT fk_upvotes_entities FOREIGN KEY (applies_to_id) REFERENCES entities(id);"
    execute "ALTER TABLE anteups ADD CONSTRAINT fk_anteups_entities FOREIGN KEY (applies_to_id) REFERENCES entities(id);"
    execute "ALTER TABLE awards ADD CONSTRAINT fk_awards_entities FOREIGN KEY (applies_to_id) REFERENCES entities(id);"
    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_users FOREIGN KEY (author_id) REFERENCES users(id);"
    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_rules FOREIGN KEY (rule_id) REFERENCES rules(id);"
    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_feed_tags FOREIGN KEY (feed_id) REFERENCES tags(id);"
    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_category_tags FOREIGN KEY (category_id) REFERENCES tags(id);"
  end

  def down
  end
end
