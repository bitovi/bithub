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
      event_hash = {
        props: {
          type: event['type'].snake_case,
          feed: feed,
          origin_id: event['id'],
          origin_author_name: event['actor']['login'],
          origin_author_id: event['actor']['id'],
          origin_author_gravatar: event['actor']['gravatar_id'],
        },
        origin_ts: parsed_date.strftime("%FT%T%z"),
        hash_key: event['hash_key'],
        raw_json: event
      }

      if event['type'] == 'IssuesEvent' 
        state = event['payload']['issue']['state']
        event_hash['title'] = "#{state} an issue: #{event['payload']['issue']['title']}"
        event_hash['body'] = event['payload']['issue']['body']
        event_hash['url'] = event['payload']['issue']['html_url']
        event_hash['props']['labels'] = event['payload']['issue']['labels'].map { |l| l['name'] }
        event_hash['props']['state'] = state
        event_hash['props']['issue_id'] = event['payload']['issue']['id']
        event_hash['props']['action'] = event['payload']['action']

      elsif event['type'] == 'IssueCommentEvent'
        event_hash['title'] = "commented on issue #{event['payload']['issue']['number']}"
        event_hash['body'] = event['payload']['comment']['body']
        event_hash['url'] = event['payload']['issue']['html_url']
        event_hash['props']['issue_id'] = event['payload']['issue']['id']

      elsif event['type'] == 'ForkEvent'
        event_hash['title'] = "forked #{event['repo']['name']}"

      elsif event['type'] == 'PushEvent'
        event_hash['title'] = "pushed to #{event['repo']['name']}"
        event_hash['body'] = event['payload']['body']
        event_hash['url'] = "http://github.com/#{event['repo']['name']}/commit/#{event['payload']['head']}"

      elsif event['type'] == 'PullRequestEvent'
        event_hash['title'] = "requested a pull: #{event['payload']['pull_request']['title']}"
        event_hash['body'] = event['payload']['pull_request']['body']
        event_hash['url'] = event['payload']['pull_request']['html_url']

      elsif event['type'] == 'WatchEvent'
        event_hash['title'] = "started watching #{event['repo']['name']}"

      elsif event['type'] == 'CommitCommentEvent'
        event_hash['title'] = "commented on a commit in #{event['repo']['name']}"
        event_hash['body'] = event['payload']['comment']['body']
        event_hash['url'] = event['payload']['comment']['html_url']

      elsif event['type'] == 'CreateEvent'
        event_hash['title'] = "created created a new #{event['payload']['ref_type']} in #{event['repo']['name']}"
      
      elsif event['type'] == 'DeleteEvent'
        event_hash['title'] = "deleted a #{event['payload']['ref_type']} from #{event['repo']['name']}"

      end
      event_hash
    end
  end
end
