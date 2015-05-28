class CreateIndexOnEntitiesParentId < ActiveRecord::Migration
  def up
    execute <<-SQL
      create index entities_parent_id_idx on entities (parent_id);
    SQL
  end

  def down
    execute <<-SQL
      drop index entities_parent_id_idx;
    SQL
  end
end
