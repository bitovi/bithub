namespace :data do
  desc "Tags events with bithub repo name (stealjs, documentjs)"

  repo_tags = {
    'steal' => 'stealjs',
    'documentjs' => 'documentjs'
  }

  task :tag_events_with_repo_name => :environment do
    repo_tags.keys.each do |repo|
      count = 0
      tag = repo_tags[repo]

      Event.where("events.props -> 'repo_name' = 'bitovi/#{repo}'").each do |e|
        if not e.tag_list.include?(tag)
          e.tag_list.add(tag)
          e.save!
          count += 1
        end
      end

      puts "#{count} events tagged with '#{tag}'"
    end
    
  end
end
