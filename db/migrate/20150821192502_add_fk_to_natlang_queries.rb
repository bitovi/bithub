class AddFkToNatlangQueries < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM natlang_queries WHERE NOT EXISTS (SELECT 1 FROM filters WHERE filters.id = natlang_queries.filter_id);
      ALTER TABLE natlang_queries DROP CONSTRAINT IF EXISTS fk_natlang_queries_to_filters;
      ALTER TABLE natlang_queries ADD CONSTRAINT fk_natlang_queries_to_filters FOREIGN KEY (filter_id) REFERENCES filters (id) ON DELETE CASCADE;
    SQL
  end

  def drop
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE natlang_queries DROP CONSTRAINT IF EXISTS fk_natlang_queries_to_filters;
    SQL
  end
end
