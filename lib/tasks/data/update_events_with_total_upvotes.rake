namespace :data do
  desc "Update total_upvotes for all events"

  task :update_events_with_total_upvotes => :environment do
    command = <<-SQL
      UPDATE events SET total_upvotes = event_total_upvotes.upvotes_sum
      FROM event_total_upvotes
      WHERE events.id = event_total_upvotes.event_id;
    SQL

    puts "---"
    puts "Updating total_upvotes (cached upvotes) for all events"
    Upvote.all.map(&:touch)
    puts "Cached upvotes updated"
  end
end
