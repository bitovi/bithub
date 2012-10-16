module Handler
  class Github < Base

    def fetch
      get_github_events = EM::HttpRequest.new('https://api.github.com/orgs/jupiterjs/events').get

      get_github_events.callback do
        github_events = Yajl::Parser.parse(get_github_events.response)

        new_events = filter_old github_events
        events_to_store = rename_attrs_in new_events
        store(events_to_store) if events_to_store.size > 0
      end

      get_github_events.errback do
        @log.error "#{feed} error: #{get_github_events.response_header.status}, header: #{get_github_events.response_header}, response: #{get_github_events.response}"
      end
    end
    
    def filter_old(feed_events)
      feed_events.each {|e| e['hash_key'] = Digest::MD5.hexdigest(e['id']+self.feed)}
      super(feed_events)
    end

    def rename_attrs_in(new_events)
      new_events.collect do |event|
        handle_event_type(event)
      end
    end

    def handle_event_type(event)
      hash = {
        type: event['type'],
        feed: feed,
        timestamp: event['created_at'],
        actor: event['actor']['login'],
        hash_key: event['hash_key']
        # raw_data: Base64::encode64(event_json)
      }

      if event['type'] == 'IssuesEvent' 
        hash['title'] = "raised an issue: #{event['payload']['issue']['title']}"
        hash['body'] = event['payload']['issue']['body']
        hash['link'] = event['payload']['issue']['html_url']

      elsif event['type'] == 'IssueCommentEvent'
        hash['title'] = "commented on issue #{event['payload']['issue']['number']}"
        hash['body'] = event['payload']['comment']['body']
        hash['link'] = event['payload']['issue']['html_url']

      elsif event['type'] == 'ForkEvent'
        hash['title'] = "forked #{event['repo']['name']}"

      elsif event['type'] == 'PushEvent'
        hash['body'] = event['payload']['body']
        hash['title'] = "pushed to #{event['repo']['name']}"

      elsif event['type'] == 'PullRequestEvent'
        hash['title'] = "requested a pull: #{event['payload']['pull_request']['title']}"
        hash['body'] = event['payload']['pull_request']['body']
        hash['link'] = event['payload']['pull_request']['html_url']

      elsif event['type'] == 'WatchEvent'
        hash['title'] = "started watching #{event['repo']['name']}"

      elsif event['type'] == 'CommitCommentEvent'
        hash['title'] = "commented on a commit in #{event['repo']['name']}"
        hash['link'] = event['payload']['comment']['html_url']

      elsif event['type'] == 'CreateEvent'
        hash['title'] = "created created a new #{event['payload']['ref_type']} | #{event['repo']['name']}"
        #hash['link'] = event['payload']['comment']['html_url']

      end
      hash
    end
  end
end

# if new_events.size >= 25
#   EM.add_timer(1.5, &github)
# end
