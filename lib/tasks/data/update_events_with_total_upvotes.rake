namespace :data do
  desc "Update total_upvotes for all events"

  task :update_total_upvotes => :environment do
    puts "Updating total_upvotes for all events"
    Upvote.all.map(&:touch)
    puts "Upvotes updated"
  end
end
