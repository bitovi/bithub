namespace :data do

  desc "Clean up duplicate internals."
  task :clean_duplicate_internals => :environment do
    puts "Cleaning duplicate internals"
    User.all.each do |user|
      Users::DuplicateInternalsCleaner.new(user).execute
      puts "Cleaned data for #{user.name}"
    end
    UserActivity.refresh
  end
end

