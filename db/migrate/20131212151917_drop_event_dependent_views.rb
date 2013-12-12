class DropEventDependentViews < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS event_total_upvotes;"
    execute "DROP VIEW IF EXISTS user_total_score;"
    execute "DROP VIEW IF EXISTS event_aggregated_tag_list;"
    
    execute "DROP MATERIALIZED VIEW IF EXISTS pagination;"
    execute "DROP MATERIALIZED VIEW IF EXISTS leaderboard;"
  end
  
  def down
  end
end
