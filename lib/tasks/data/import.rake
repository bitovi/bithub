namespace :data do
  desc "Imports data needed for the app to work"
  task :import => :environment do
    Rake::Task["data:import_or_update_countries"].execute
    Rake::Task["data:import_or_update_tags"].execute
    Rake::Task["data:import_scoring_rules"].execute
    Rake::Task["data:create_or_reset_admin_account"].execute
  end
end
