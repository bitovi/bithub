namespace :data do
  task :add_issue_state_to_tags => :environment do

    puts "---"
    puts "Adding props[state] to tags."

    summary = Hash.new(0)
    failed = []
 
    Event.where("props ? 'state'").each do |e|      
      state = e.props["state"]      
      e.tag_list.add(state)

      if e.save
        summary[state] += 1
      else
        failed.push e.id        
      end      
    end

    puts "Summary:"
    summary.each {|k,v| puts "  '#{k}' matched for #{v} events"}
    puts "   Saving failed for #{failed.length} events!: #{failed.to_s}"

  end
end
