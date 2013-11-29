namespace :data do
  desc "Run all tasks needed for deployment"
  task :priority_1 => :environment do
    #Rake::Task["data:import_category_determination_rules"].execute
    Rake::Task["data:import_or_update_tags"].execute
    #Rake::Task["data:cleanup_tag_duplicates"].execute
    Rake::Task["data:feed_and_category_into_props"].execute
    #Rake::Task["data:clean_junk_tags"].execute
    Rake::Task["data:update_events_with_cached_tags"].execute
    Rake::Task["data:update_events_with_total_upvotes"].execute
    Rake::Task["data:update_users_with_total_score"].execute
  end
end
