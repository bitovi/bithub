module Handler
  class Github < Base

    def self.handler(log, exchange, endpoint)
      new(log, exchange, endpoint).handler
    end

    def initialize(log, exchange, endpoint)
      @endpoint = endpoint || 'https://api.github.com/orgs/bitovi/events'
      super(log,exchange)
    end

    def fetch
      get_github_events = EM::HttpRequest.new(@endpoint)
                                         .get(:head => {"Authorization" => "token f5e07c1c541c31821e7c71219687a4c045c880a9"})

      get_github_events.callback do
        # DEBUG (CHECKING RATELIMIT_REMAINING)
        # @log.info get_github_events.response_header
        github_events = Yajl::Parser.parse(get_github_events.response)

        new_events = filter_old github_events
        events_to_store = rename_attrs_in new_events
        store(events_to_store) if events_to_store.size > 0
      end

      get_github_events.errback do
        @log.error "#{feed} error: Response: #{get_github_events.response}"
      end
    end
    
    def filter_old(feed_events)
      feed_events.each do |e|
        begin
          e['hash_key'] = Digest::MD5.hexdigest(e['id'].to_s + feed.to_s)
        rescue TypeError => error
          @log.error error
          @log.error "FEED: #{feed} | DATA: #{e}"
        end
      end
      super(feed_events)
    end

    def rename_attrs_in(new_events)
      new_events.collect do |event|
        handle_event_type(event)
      end
    end

    def handle_event_type(event)
      parsed_date = Time.strptime(event['created_at'], "%FT%T%Z")
      hash = {
        type: event['type'].downcase,
        feed: feed,
        created_ts: parsed_date.strftime("%FT%T%z"),
        actor: event['actor']['login'],
        actor_id: event['actor']['id'],
        actor_gravatar: event['actor']['gravatar_id'],
        source_id: event['id'],
        hash_key: event['hash_key'],
        source_data: event
      }

      if event['type'] == 'IssuesEvent' 
        state = event['payload']['issue']['state']
        hash['title'] = "#{state} an issue: #{event['payload']['issue']['title']}"
        hash['body'] = event['payload']['issue']['body']
        hash['link'] = event['payload']['issue']['html_url']
        hash['labels'] = event['payload']['issue']['labels'].map { |l| l['name'] }
        hash['state'] = state
        hash['issue_id'] = event['payload']['issue']['id']
        hash['action'] = event['payload']['action']

      elsif event['type'] == 'IssueCommentEvent'
        hash['title'] = "commented on issue #{event['payload']['issue']['number']}"
        hash['body'] = event['payload']['comment']['body']
        hash['link'] = event['payload']['issue']['html_url']
        hash['issue_id'] = event['payload']['issue']['id']

      elsif event['type'] == 'ForkEvent'
        hash['title'] = "forked #{event['repo']['name']}"

      elsif event['type'] == 'PushEvent'
        hash['body'] = event['payload']['body']
        hash['title'] = "pushed to #{event['repo']['name']}"
        hash['link'] = "http://github.com/#{event['repo']['name']}/commit/#{event['payload']['head']}"

      elsif event['type'] == 'PullRequestEvent'
        hash['title'] = "requested a pull: #{event['payload']['pull_request']['title']}"
        hash['body'] = event['payload']['pull_request']['body']
        hash['link'] = event['payload']['pull_request']['html_url']

      elsif event['type'] == 'WatchEvent'
        hash['title'] = "started watching #{event['repo']['name']}"

      elsif event['type'] == 'CommitCommentEvent'
        hash['title'] = "commented on a commit in #{event['repo']['name']}"
        hash['body'] = event['payload']['comment']['body']
        hash['link'] = event['payload']['comment']['html_url']

      elsif event['type'] == 'CreateEvent'
        hash['title'] = "created created a new #{event['payload']['ref_type']} in #{event['repo']['name']}"
      
      elsif event['type'] == 'DeleteEvent'
        hash['title'] = "deleted a #{event['payload']['ref_type']} from #{event['repo']['name']}"

      end
      hash
    end
  end
end
