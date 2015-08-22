namespace :data do
  desc "Imports data needed for the app to work"
  task :import => :environment do
    puts "--- BEGIN data:import"
    Rake::Task["data:import_or_update_countries"].execute
    Rake::Task["data:import_plans"].execute
    Rake::Task["data:import_invite_codes"].execute if Rails.env.development?
    # Rake::Task["data:create_or_reset_admin_account"].execute
    puts "--- END data:import"
  end
end
