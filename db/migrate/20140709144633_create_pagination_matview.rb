class CreatePaginationMatview < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE MATERIALIZED VIEW pagination AS
SELECT e.thread_updated_ts AS ts,
    e.id,
    string_to_array(e.cached_tag_list, ', ')::character varying[] AS tags,
    funnels.name AS funnel
    FROM entities e
        LEFT JOIN ( SELECT f.name, fc.feed_name, fc.type_name, f.tags
	   FROM funnels f
	     LEFT JOIN funnel_constraints_funnels fcf ON fcf.funnel_id = f.id
	     LEFT JOIN funnel_constraints fc ON fcf.funnel_constraint_id = fc.id
	) AS funnels ON e.feed_name = funnels.feed_name AND e.type_name = funnels.type_name AND (funnels.tags = '{}' OR funnels.tags && string_to_array(e.cached_tag_list,', ')::character varying[])
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
