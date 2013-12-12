class RecreatePaginationMatview < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS pagination;"
    execute <<-SQL
      CREATE MATERIALIZED VIEW pagination AS
        SELECT e.thread_updated_date::date AS "date",
               e.id AS id,
               categories.name AS category,
               ARRAY(
                 SELECT t.name
                   FROM taggings AS tt, tags AS t
                   WHERE tt.taggable_type = 'Event' AND tt.tag_id = t.id AND tt.taggable_id = e.id
               ) AS tags
	      FROM events AS e
            LEFT JOIN tags AS categories ON e.category_id = categories.id
          WHERE e.parent_id IS NULL
	      ORDER BY e.thread_updated_date DESC;
    SQL
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS pagination;"
  end
end
