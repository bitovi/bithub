namespace :data do
  desc "Sets cached_tags attribute for all events"

  task :update_events_with_cached_tags => :environment do
    command = <<-SQL
      UPDATE events SET cached_tag_list = event_aggregated_tag_list.tag_list
      FROM event_aggregated_tag_list
      WHERE events.id = event_aggregated_tag_list.event_id;
    SQL

    puts "---"
    puts "Updating cached_tag_list for all events"
    ActiveRecord::Base.connection.execute(command)
    puts "Tag list updated"
  end
end
