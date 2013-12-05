namespace :data do
  task :delete_follow_events_with_nonbitovi_target => :environment do

    VALID_TARGETS = ['canjs', 'javascriptmvc', 'bitovi', 'jquerypp', 'funcunit']
    
    puts "---"
    puts "Deleting follow events with non-bitovi target"

    events = Event.tagged_with('follow_event')
    counter = []
    
    events.each do |e|
      screen_name = e.source_data.andand['target'].andand['screen_name']
      if screen_name && !VALID_TARGETS.include?(screen_name)
        e.destroy
        counter.push screen_name
      end
    end

    puts "#{counter.length} events deleted with targets #{counter.to_s}"

  end
end
