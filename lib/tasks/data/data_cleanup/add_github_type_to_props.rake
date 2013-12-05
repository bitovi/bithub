namespace :data do
  task :add_github_type_to_props => :environment do

    puts "---"
    puts "Setting props[type] on Github events"

    events = Event.tagged_with('github').where("(props -> 'type') is null")
    summary = {
      'not_mached' => 0
    }
    failed = []
 
    events.each do |e|      

      if type = e.source_data['type'].snake_case
        e.props['type'] = type

        if e.save
          summary[type] = summary[type] ? summary[type]+1 : 1
        else
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
