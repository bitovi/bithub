class AddContraintsOnEntityRefs < ActiveRecord::Migration
  def up
    execute "ALTER TABLE entity_refs ADD CONSTRAINT entity_refs_unique_from_to UNIQUE (from_id, to_id)"
    execute "CREATE INDEX entity_refs_on_from_id ON entity_refs (from_id);"
    execute "CREATE INDEX entity_refs_on_to_id ON entity_refs (to_id);"
  end

  def down
    execute "ALTER TABLE entity_refs DROP CONSTRAINT IF EXISTS entity_refs_unique_from_to"
    execute "DROP INDEX IF EXISTS entity_refs_on_from_id;"
    execute "DROP INDEX IF EXISTS entity_refs_on_to_id;"
  end
end
