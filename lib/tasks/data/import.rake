namespace :data do
  desc "Imports data needed for the app to work"
  task :import=> :environment do
    Rake::Task["data:import_category_determination_rules"].execute
    Rake::Task["data:import_countries"].execute
  end
end

