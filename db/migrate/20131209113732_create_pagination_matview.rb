class CreatePaginationView < ActiveRecord::Migration
  def up
    execute <<-SQL
      create materialized view pagination
      as
      select e.origin_date::date as "date", t.name::text as category, count (*) as cnt
      from tags as t, taggings as tt, tags as mt,
      events as e, taggings as et
      where tt.tag_id = mt.id and tt.taggable_id = t.id and tt.taggable_type = 'ActsAsTaggableOn::Tag'
      and et.tag_id = t.id and et.taggable_id = e.id and et.taggable_type = 'Event'
      and mt.name = 'categories'
      and e.parent_id is null
      group by e.origin_date, t.name
      order by e.origin_date desc;
    SQL
  end

  def down
    execute "drop materialized view pagination;"
  end
end

