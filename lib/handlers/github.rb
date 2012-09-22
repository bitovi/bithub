module Handler
  class Github < Base

    def fetch
      org_events = EM::HttpRequest.new('https://api.github.com/orgs/jupiterjs/events').get

      org_events.callback do
        github_events = Yajl::Parser.parse(org_events.response)

        ids = github_events.collect {|e| e['id']}
        new_events = github_events.reject {|e| @latest.include? e['id']}
        @latest = ids

        events = new_events.collect do |event|
          handle_event_type(event)
        end

        if new_events.size > 0
          @log.info "#{feed}: #{events.size} new events"
          store(new_events)
        else
          @log.info "#{feed}: Nothing new"
        end
      end

      org_events.errback do
        @log.error "Error: #{org_events.response_header.status}, header: #{org_events.response_header}, response: #{org_events.response}"
      end
    end

    def handle_event_type(event)
      feed = 'github'
      hash = {
            type: event['type'],
            feed: feed,
            timestamp: event['created_at'],
            username: event['actor']['login'],
            hash_key: Digest::MD5.hexdigest(event['id']+feed)
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
