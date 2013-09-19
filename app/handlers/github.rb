require 'app/processors/github/processor'

module Handler
  class Github < Base
    attr_reader :token, :endpoint, :processor

    def self.handler(log, exchange, token, endpoint=nil)
      new(log, exchange, token, endpoint).handler
    end

    def initialize(log, exchange, token, endpoint=nil)
      @token = token
      @endpoint = endpoint || 'https://api.github.com/orgs/bitovi/events'
      @processor = EventProcessor::Github.new
      super(log, exchange)
    end

    def fetch
      get_github_events = EM::HttpRequest.new(endpoint).get(:head => {"Authorization" => "token #{token}"})

      get_github_events.callback do

        if get_github_events.response_header.status.to_s == "200"
          github_events = Yajl::Parser.parse(get_github_events.response)
          new_events = filter_old github_events
          begin
            publish(process(new_events)) if new_events.size > 0
          rescue EventProcessor::Github::NotValidEventException => e
            @log.error "FEED: #{feed} | #{e}"
          end
        else
          @log.error "FEED: #{feed} | HTTP #{get_github_events.response_header.status}"
        end
      end

      get_github_events.errback do
        @log.error "FEED: #{feed} | HTTP #{get_github_events.response_header.status}"
      end
    end

    def filter_old(feed_events)
      feed_events.each do |e|
        begin
          e['hash_key'] = Digest::MD5.hexdigest(e['id'].to_s + feed.to_s)
        rescue => error
          @log.error "FEED: #{feed} | ERROR: #{error}"
        end
      end
      super(feed_events)
    end

    def process(new_events)
      new_events.map { |e| processor.process(e) }
    end

  end
end
