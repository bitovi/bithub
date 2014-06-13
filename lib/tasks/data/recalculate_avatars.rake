namespace :data do
  desc "Calls User#calculate_avatar_url"
  task :recalculate_avatars => :environment do
    puts "---"
    puts "Refreshing avatar_url in props"
    
    User.all.each do |user|
      user.calculate_avatar_url
      user.save
    end
  end
end
