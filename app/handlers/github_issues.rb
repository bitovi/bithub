require 'app/processors/github/processor'

module Handler
  class GithubIssues < Base
    attr_reader :token, :endpoint, :processor

    def self.handler(log, exchange, token, endpoint=nil)
      new(log, exchange, token, endpoint).handler
    end

    def initialize(log, exchange, token, endpoint=nil)
      @token = token
      @endpoint = endpoint || 'https://api.github.com/orgs/bitovi/issues'
      @processor = EventProcessor::Github.new
      super(log, exchange)
    end

    def fetch(endpoint = nil)
      endpoint = endpoint || @endpoint

      get_github_issues = EM::HttpRequest.new(endpoint).get(:head => {"Authorization" => "token #{token}"})

      get_github_issues.callback do

        if get_github_issues.response_header.status.to_s == "200"
          github_issues = Yajl::Parser.parse(get_github_issues.response)

          begin
            publish(github_issues) if github_issues.size > 0
          rescue EventProcessor::Github::NotValidEventException => e
            @log.error "FEED: #{feed} | #{e}"
          end

          ### fetch next page
          if get_github_issues.response_header["LINK"]
            next_link = self.get_link_by_type(get_github_issues.response_header["LINK"], 'next')
            self.fetch(next_link[:url]) if next_link
          end

        else
          @log.warning "FEED: #{feed} | HTTP #{get_github_issues.response_header.status}"
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
      new_events.map { |e| processor.process(e) }
    end

  end
end
