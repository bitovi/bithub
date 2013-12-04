namespace :data do
  task :add_github_type_to_props_and_redetermine_tags_and_category => :environment do

    puts "---"
    puts "Setting props[type] and redetermine tags and category for Github events"

    events = Event.tagged_with('github').where("(props -> 'type') is null")
    summary = {
      'not_mached' => 0
    }
    failed = []
 
    events.each do |e|      
      type = e.source_data['type'].snake_case

      if type
        e.props['type'] = type
        e.determine_tags
        e.determine_category
        if e.save
          summary[type] = summary[type] ? summary[type]+1 : 1
        else
          puts "Updating event with id #{e.id} failed!"
          failed.push e.id
        end
      else
        summary['not_matched'] += 1
      end
    end

    puts "Summary:"
    summary.each {|k,v| puts "  '#{k}' matched for #{v} events"}
    puts "   Saving failed for #{failed.length} events!: #{failed.to_s}"

  end
end
