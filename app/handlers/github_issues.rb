require 'app/processors/github/processor'

module Handler
  class GithubIssues < Base
    attr_reader :token, :endpoint, :processor, :state

    def self.handler(log, exchange, token, state, endpoint = nil)
      new(log, exchange, token, state, endpoint).handler
    end

    def initialize(log, exchange, token, state, endpoint=nil)
      @token = token
      @endpoint = endpoint || 'https://api.github.com/orgs/bitovi/issues'
      @processor = EventProcessor::Github.new
      @state = state
      super(log, exchange)
    end

    def fetch(endpoint = nil)
      endpoint = endpoint || @endpoint

      get_github_issues = EM::HttpRequest.new(endpoint).get({
        query: { state: state },
        head: {
          'Authorization' => "token #{token}",
          'Accept' => 'application/vnd.github.v3+json'
        }
      })

      get_github_issues.callback do

        if get_github_issues.response_header.status.to_s == "200"
          github_issues = Yajl::Parser.parse(get_github_issues.response)

          begin
            publish(process(github_issues)) if github_issues.size > 0
          rescue EventProcessor::Github::NotValidEventException => e
            @log.error "FEED: #{feed} | #{e}"
          end

          ### fetch next page
          if get_github_issues.response_header["LINK"]
            next_link = self.get_link_by_type(get_github_issues.response_header["LINK"], 'next')
            self.fetch(next_link[:url]) if next_link
          end

        else
          @log.warn "FEED: #{feed} | HTTP #{get_github_issues.response_header.status}"
        end
      end

      get_github_issues.errback do
        @log.error "FEED: #{feed} | HTTP #{get_github_issues.response_header.status}"
      end
    end

    def parse_link(link_header)
      # by RFC Link header can have more attributes so parsing would fail in that case
      # but github API sticks with 'rel' attr only

      parsed = []
      link_header.split(",").each do |rel|
        link, url, type = /<(.*)>; rel="(.*)"/.match(rel).to_a
        parsed.push({:link => link, :url => url, :type => type})
      end

      parsed
    end

    def get_link_by_type(link_header, type)
      filtered = self.parse_link(link_header).select do |link|
        link[:type] == type
      end
      filtered[0]
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
      new_events.map { |e| calculate_difference_hash(e) }
    end

    def calculate_difference_hash(event_hash)
      ret_hash = {}
      composite_seed = event_hash['id'].to_s +
                       event_hash['labels'].to_s +
                       event_hash['state'] +
                       event_hash['title'] +
                       event_hash['body']

      ret_hash['content_digest'] = Digest::MD5.hexdigest(composite_seed)
      ret_hash['labels'] = event_hash['labels'].map{|l| l['name'].downcase}
      ret_hash['source_data'] = event_hash
      ret_hash
    end

  end
end
