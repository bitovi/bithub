namespace :data do
  desc "Re-determine categories on all events"

  task :redetermine_categories => :environment do

    puts "---"
    puts "Redetermining categories on events"

    summary = Hash.new(0)
    
    Event.all.each do |e|
      old = e.category.name      
      e.determine_category
      new = e.category.name

      if old != new
        if e.save
          summary["#{old}->#{new}"] += 1
        else
          puts "Saving failed for #{e.id}"
        end        
      end
      
    end

    puts "Summary:"
    summary.each {|k,v| puts "  '#{k}' changed #{v} times"}
    
  end
end
