namespace :data do
  task :recalculate_achievements => :environment do
    User.all.each do |u|
      p "Processing user #{u.name}"
      u.achievements.each do |a|
        a.destroy
      end

      u.reward_if_eligible
    end
  end
end
