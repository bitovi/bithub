namespace :data do
  task :add_twitter_type_to_props => :environment do

    puts "---"
    puts "Setting props[type] on Twitter events"

    events = Event.tagged_with('twitter').where("(props -> 'type') is null")
    summary = Hash.new(0)
    failed = []
 
    events.each do |e|      
      if e.source_data['event'] == 'follow'
        type = 'follow_event'
      elsif e.source_data['text'] && e.source_data['created_at']
        type = 'status_event'
      end
      
      e.props['type'] = type
      
      if e.save
        summary[type] += 1
      else
        failed.push e.id
      end
      
    end

    puts "Summary:"
    summary.each {|k,v| puts "  '#{k}' matched for #{v} events"}
    puts "   Saving failed for #{failed.length} events!: #{failed.to_s}"

  end
end
