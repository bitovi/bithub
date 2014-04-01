class CreatePaginationMatview < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE MATERIALIZED VIEW pagination AS
 SELECT e.thread_updated_ts AS ts,
    e.id,
    categories.name AS category,
    ARRAY( SELECT t.name
           FROM taggings tt,
            tags t
          WHERE tt.taggable_type::text = 'Entity'::text AND tt.tag_id = t.id AND tt.taggable_id = e.id) AS tags
   FROM entities e
   LEFT JOIN tags categories ON e.category_id = categories.id
  WHERE e.parent_id IS NULL
  ORDER BY e.thread_updated_ts DESC
WITH DATA;
    SQL

    execute <<-SQL
REFRESH MATERIALIZED VIEW pagination;
    SQL
  end

  def down
    execute "drop materialized view pagination;"
  end
end
