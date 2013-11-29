namespace :data do
  desc "Run all tasks needed for deployment"
  task :priority_1 => :environment do
    Rake::Task["data:import_category_determination_rules"].execute
    Rake::Task["data:import_or_update_tags"].execute

    Rake::Task["data:update_events_props_with_feed_and_category"].execute
    Rake::Task["data:update_events_with_cached_tags"].execute
    Rake::Task["data:update_events_with_total_upvotes"].execute
    Rake::Task["data:update_users_with_total_score"].execute
    
    #Rake::Task["data:recalculate_achievements"].execute
  end
end
