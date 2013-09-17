namespace :db do
  desc "Drops and recreates the database"
  task :recreate_and_seed => :environment do
    Rake::Task["db:drop"].execute
    Rake::Task["db:create"].execute
    Rake::Task["db:migrate"].execute
    Rake::Task["db:seed"].execute
  end
end
