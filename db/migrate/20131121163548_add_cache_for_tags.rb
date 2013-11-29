class AddCacheForTags < ActiveRecord::Migration
  def up
    add_column :events, :cached_tag_list, :string
    
    execute <<-SQL
      CREATE VIEW event_aggregated_tag_list AS
      SELECT e.id AS event_id, string_agg(t.name, ',') AS tag_list
      FROM events AS e, tags AS t, taggings AS e_t
      WHERE e.id = e_t.taggable_id AND e_t.tag_id = t.id
      GROUP BY e.id;
    SQL
  end

  def down
    remove_column :events, :cached_tag_list

    execute <<-SQL
      DROP VIEW IF EXISTS event_cached_tag_list;
    SQL
  end
end
