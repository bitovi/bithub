namespace :data do
  desc "Apply snake_case to every event.feed_name and event.type_name"
  task :event_feed_type_names_to_snake_case => :environment do

    puts "---"
    puts "\nUpdating Twitter identities with new profile imgs"

    Event.find_each do |event|
      event.feed_name = event.feed_name.snake_case
      event.type_name = event.type_name.snake_case
      event.save
    end
    
  end
end
