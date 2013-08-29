module Handler
  class Github < Base
    attr_reader :token, :endpoint

    EVENT_TYPES = {
      "CommitCommentEvent" => lambda {|event|
        {
          :title => "commented on a commit in #{event['repo']['name']}",
          :body => event['payload']['comment']['body'],
          :url => event['payload']['comment']['html_url'],
          :meta => {:commit_id => event['payload']['comment']['commit_id'] }
        }
      },                                    
      "CreateEvent" => lambda {|event|
        {
          :title => "created created a new #{event['payload']['ref_type']} in #{event['repo']['name']}"
        }
      },
      "DeleteEvent" => lambda {|event|
        {
          :title => "deleted a #{event['payload']['ref_type']} from #{event['repo']['name']}"
        }
      },
      "DownloadEvent" => lambda {|event|
        {
          :title => "download #{event['payload']['download']['name']} created",
          :body => event['payload']['download']['description'],
          :url => event['payload']['download']['html_url']
        }
      },
      "FollowEvent" => lambda {|event|
        {
          :title => "followed #{event['repo']['name']}"
        }
      },
      "ForkEvent" => lambda {|event|
        {
          :title => "forked #{event['repo']['name']}"
        }
      },
      "ForkApplyEvent" => lambda {|event|
        {
          :title => "patch applied on #{event['repo']['name']}"
        }
      },
      "GistEvent" => lambda {|event|
        {
          :title => "Gist #{event['payload']['action']}: #{event['payload']['gist']['description']}",
          :url => event['payload']['gist']['url'],
          :meta => {
            :action => event['payload']['action']
          }
        }
      },
      "GollumEvent" => lambda {|event|
        event_hash = {
          :title => "gollum event",
          :meta => { :pages => [] }
        }
        event['payload']['pages'].each do |page|
          event_hash[:meta][:pages].push({:title => page['title'], :url => page['html_url']})
        end
        event_hash
      },
      "IssueCommentEvent" => lambda {|event|
        {
          :title => "commented on issue #{event['payload']['issue']['number']}",
          :body => event['payload']['comment']['body'],
          :url => event['payload']['issue']['html_url'],
          :meta => {:issue_id => event['payload']['issue']['id'] }
        }
      },
      "IssuesEvent" => lambda {|event|
        state = event['payload']['issue']['state']
        {
          :title => event['payload']['issue']['title'],
          :body => event['payload']['issue']['body'],
          :url => event['payload']['issue']['html_url'],
          :meta => {
            :labels => event['payload']['issue']['labels'].map { |l| l['name'] },
            :state => state,
            :issue_id => event['payload']['issue']['id'],
            :action => event['payload']['action']
          }
        }
      },
      "MemberEvent" => lambda {|event|
        {
          :title => "Member #{event['payload']['member']['login']} added to #{event['repo']['name']}"
        }
      },
      "PublicEvent" => lambda {|event|
        {
          :title => "Repository #{event['repo']['name']} goes public!"
        }
      },
      "PullRequestEvent" => lambda {|event|
        {
          :title => "requested a pull: #{event['payload']['pull_request']['title']}",
          :body => event['payload']['pull_request']['body'],
          :url => event['payload']['pull_request']['html_url']
        }
      },
      "PullRequestReviewCommentEvent" => lambda {|event|
        {
          :title => "commented on pull request review #{event['payload']['issue']['number']}",
          :url => event['payload']['comment']['_links']['html'],
          :body => event['payload']['comment']['body']
        }
      },
      "PushEvent" => lambda {|event|
        event_hash = {
          :title => "pushed to #{event['repo']['name']}",
          :body => event['payload']['body'],
          :url => "http://github.com/#{event['repo']['name']}/commit/#{event['payload']['head']}",
          :meta => {:commits => ""}
        }

        event['payload']['commits'].each do |commit|
          event_hash[:meta][:commits] += commit['sha'] + ","
        end

        event_hash
      },
      "TeamAddEvent" => lambda {|event|
        {
          :title => "team add event"
        }
      },
      "WatchEvent" => lambda {|event|
        {
          :title => "started watching #{event['repo']['name']}"
        }
      }
    }

    def self.handler(log, exchange, token, endpoint=nil)
      new(log, exchange, token, endpoint).handler
    end

    def initialize(log, exchange, token, endpoint=nil)
      @token = token
      @endpoint = endpoint || 'https://api.github.com/orgs/bitovi/events'
      super(log, exchange)
    end

    def fetch
      get_github_events = EM::HttpRequest.new(endpoint).get(:head => {"Authorization" => "token #{token}"})

      get_github_events.callback do
        if get_github_events.response_header.status.to_s == "200"
          github_events = Yajl::Parser.parse(get_github_events.response)
          new_events = filter_old github_events
          events_to_store = rename_attrs_in new_events
          store(events_to_store) if events_to_store.size > 0
        else
          # sometimes github API returns 500
          @log.error "SKIPPING -> Github API returned HTTP response with code #{get_github_events.response_header.status}"
        end
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
        self.class.prepare_event(event, {:feed => feed})
      end
    end

    def self.prepare_event(event, opts)

      # Github provides date in format: "2013-02-14T22:47:29Z"
      parsed_date = Time.parse(event['created_at']).utc

      event_hash = {
        :meta => {
          :type => event['type'].snake_case,
          :feed => opts[:feed],
          :origin_id => event['id'],
          :origin_author_name => event['actor']['login'],
          :origin_author_id => event['actor']['id'],
          :origin_author_gravatar => event['actor']['gravatar_id']
        },
        :origin_ts => parsed_date.iso8601,
        :origin_date => parsed_date.strftime("%Y-%m-%d"),
        :hash_key => event['hash_key'],
        :source_data => event
      }

      event_hash.deep_merge(EVENT_TYPES[event['type']].call event)
    end

  end
end
