namespace :data do
  desc "Fills API cache with followers/stargazers of importat accounts/repos."

  task :clean_duplicate_internals => :environment do
    User.all do |user|
      DuplicateInternalsCleaner.new(user).execute
    end
  end
end

