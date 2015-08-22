namespace :data do
  desc "Imports data needed for development"
  task :seed => :environment do
    puts "--- BEGIN seed"
    Rake::Task["data:dev_crawler_config"].execute
    puts "--- END seed"
  end
end

