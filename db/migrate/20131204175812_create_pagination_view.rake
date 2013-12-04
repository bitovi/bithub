class CreatePaginationView < ActiveRecord::Migration
  def up
    execute <<-SQL
      create materialized view pagination
      as
      select e.origin_date, t.name as category, count (*) as evs_in_cat
      from tags as t, taggings as tt, tags as mt,
      events as e, taggings as et
      where tt.tag_id = mt.id and tt.taggable_id = t.id and tt.taggable_type = 'ActsAsTaggableOn::Tag'
      and et.tag_id = t.id and et.taggable_id = e.id and et.taggable_type = 'Event'
      and mt.name = 'categories'
      and t.name = 'question'
      group by e.origin_date, t.name
      order by e.origin_date desc;
    SQL
  end

  def down
    execute <<-SQL
      drop materialized view pagination;
    SQL
  end
end

