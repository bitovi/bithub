namespace :data do
  desc "Imports data needed for development"
  task :seed => :environment do
    Rake::Task["data:dev_crawler_config"].execute
  end
end

