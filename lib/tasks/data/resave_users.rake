namespace :data do
  desc "Re-saves users (triggers pre/after hooks)"
  task :resave_users => :environment do
    User.all.each {|user| user.save}
  end
end
