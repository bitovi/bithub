namespace :db do
  desc "Drops and recreates the database"
  task :recreate => :environment do
    begin
      Rake::Task["db:drop"].execute
    rescue Exception => e
      # continue in a case that db does not exists :/
    end
    Rake::Task["db:create"].execute
    Rake::Task["db:migrate"].execute
    Rake::Task["data:import"].execute
  end
end
