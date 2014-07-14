class CreateEntityAggregatedTagListView < ActiveRecord::Migration
  def up
    execute <<-CACHED_TAG_LIST
      CREATE VIEW entity_aggregated_tag_list AS
      SELECT e.id AS entity_id, string_agg(t.name, ',') AS tag_list
      FROM entities AS e, tags AS t, taggings AS e_t
      WHERE e.id = e_t.taggable_id AND e_t.tag_id = t.id
      GROUP BY e.id;
    CACHED_TAG_LIST
  end

  def down
  end
end
