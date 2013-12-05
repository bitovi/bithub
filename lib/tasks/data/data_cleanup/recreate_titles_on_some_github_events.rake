namespace :data do
  task :recreate_titles_on_some_github_events => :environment do

    puts "---"
    puts "Recreating titles on gollum, public and pull req review comment events."

    types = {
      'gollum_event' => Proc.new do |e|
        sd = e.source_data
        
        e.title = "wiki updated on #{sd['repo']['name']}"
        e.props['pages'] = sd['payload']['pages'].map {|p| {:title => p['title'], :url => p['html_url']}}
      end,
      
      'public_event' => Proc.new do |e|
        sd = e.source_data
        
        e.title = "Repository #{sd['repo']['name']} goes public!"
      end,
      
      'pull_request_review_comment_event' => Proc.new do |e|
        comment = e.source_data['payload']['comment']
        
        e.title = "commented on pull request: #{comment['path']}"
        e.url = comment['_links']['html']['href']
        e.body = comment['body']
      end
    }

    events = Event.tagged_with(types.keys, :any => true)
    updated = []
    failed = []
 
    events.each do |e|
      type = e.props['type'] || e.source_data['type'].snake_case
      types[type].call(e)
      e.save ? updated.push(e.id) : failed.push(e.id)
    end

    puts "Summary:"
    puts "  #{updated.length} events updated"
    puts "  #{failed.length} updates FAILED: #{failed.to_s}"

  end
end
