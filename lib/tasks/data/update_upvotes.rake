namespace :data do
  desc "Update total_upvotes column on events"

  task :update_upvotes => :environment do
    Upvote.all.map{|u| u.touch}
    puts "Upvotes updated"
  end
end
