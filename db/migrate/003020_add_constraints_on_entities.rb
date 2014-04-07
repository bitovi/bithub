class AddConstraintsOnEntities < ActiveRecord::Migration
  def up
    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_feed_tags FOREIGN KEY (feed_id) REFERENCES tags(id);"
    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_type_tags FOREIGN KEY (type_id) REFERENCES tags(id);"
    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_category_tags FOREIGN KEY (category_id) REFERENCES tags(id);"

    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_scoring_rules FOREIGN KEY (scoring_rule_id) REFERENCES scoring_rules(id);"

    execute "ALTER TABLE ownerships ADD CONSTRAINT fk_ownerships_users FOREIGN KEY (owner_id) REFERENCES users(id);"
    execute "ALTER TABLE ownerships ADD CONSTRAINT fk_ownerships_entities FOREIGN KEY (entity_id) REFERENCES entities(id);"

    execute "ALTER TABLE entity_refs ADD CONSTRAINT entity_refs_unique_from_to UNIQUE (from_id, to_id)"

    execute "CREATE INDEX entity_refs_on_from_id ON entity_refs (from_id);"
    execute "CREATE INDEX entity_refs_on_to_id ON entity_refs (to_id);"
  end

  def down
    execute "ALTER TABLE entities DROP CONSTRAINT IF EXISTS fk_entities_feed_tags"
    execute "ALTER TABLE entities DROP CONSTRAINT IF EXISTS fk_entities_type_tags"
    execute "ALTER TABLE entities DROP CONSTRAINT IF EXISTS fk_entities_category_tags"
    execute "ALTER TABLE entities DROP CONSTRAINT IF EXISTS fk_entities_scoring_rules"

    execute "ALTER TABLE entities DROP CONSTRAINT IF EXISTS fk_ownerships_users"
    execute "ALTER TABLE entities DROP CONSTRAINT IF EXISTS fk_ownerships_entities"

    execute "ALTER TABLE entity_refs DROP CONSTRAINT IF EXISTS entity_refs_unique_from_to"

    execute "DROP INDEX IF EXISTS entity_refs_on_from_id;"
    execute "DROP INDEX IF EXISTS entity_refs_on_to_id;"
  end
end
