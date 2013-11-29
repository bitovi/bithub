namespace :data do
  desc "Updates total_score for all users."

  task :update_total_score => :environment do
    puts "Updating total_score for all users"
    User.all.each do |u|
      u.update_attribute(:total_score, u.score)
    end
    puts "Score updated"
  end
end
