class DropUserActivitiesMatView < ActiveRecord::Migration
  def change
    execute 'DROP MATERIALIZED VIEW IF EXISTS user_activities;'
  end
end
