namespace :data do
  desc "Recreates titles for github create and delete events"

  task :recreate_titles_on_create_and_delete_events => :environment do
    count = 0

    Event.tagged_with('create_event').each do |e|
      e.title = "created a new #{e['source_data']['payload']['ref_type']} on #{e['source_data']['repo']['name']}: #{e['source_data']['payload']['ref']}"
      e.save!
      count += 1
    end

    puts "#{count} create events updated"
    count = 0

    Event.tagged_with('delete_event').each do |e|
      e.title = "deleted a #{e['source_data']['payload']['ref_type']} from #{e['source_data']['repo']['name']}: #{e['source_data']['payload']['ref']}"
      e.save!
      count += 1
    end

    puts "#{count} delete events updated"

  end
end
