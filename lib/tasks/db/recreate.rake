namespace :db do
  desc "Drops and recreates the database"
  task :recreate => :environment do
    Rake::Task["db:drop"].execute rescue nil
    Rake::Task["db:create"].execute
    Rake::Task["db:migrate"].execute
    Rake::Task["data:import"].execute
  end
end
