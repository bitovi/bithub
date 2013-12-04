namespace :data do
  task :recreate_titles_and_pages_on_gollum_events => :environment do

    puts "---"
    puts "Recreating titles and props[pages] on gollum events"

    events = Event.tagged_with('gollum_event')
    updated = []
    failed = []
 
    events.each do |e|
      sd = e['source_data']
      
      e.title = "wiki updated on #{sd['repo']['name']}"
      e.props['pages'] = sd['payload']['pages'].map {|p| {:title => p['title'], :url => p['html_url']}}
      
      e.save ? updated.push(e.id) : failed.push(e.id)
    end

    puts "Summary:"
    puts "  #{updated.length} events updated"
    puts "  #{failed.length} updates FAILED: #{failed.to_s}"

  end
end
