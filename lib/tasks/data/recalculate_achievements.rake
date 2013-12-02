namespace :data do
  task :recalculate_achievements => :environment do
    puts "---"
    puts "Recalculating achievements for all users"

    User.all.each do |u|
      u.achievements.each {|a| a.destroy}
      u.reward_if_eligible
    end

    puts "Achievements recalculated"
  end
end
