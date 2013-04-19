module Handler
  class Blog < Base
    
    def fetch
      get_blog_events = EM::HttpRequest.new('http://www.bitovi.com/blog.rss').get

      get_blog_events.callback do
        blog_events = @parser.parse(get_blog_events.response)['rss']['channel']['item']

        new_events = filter_old blog_events
        events_to_store = rename_attrs_in new_events
        store(events_to_store) if events_to_store.size > 0
      end

      get_blog_events.errback do
        @log.error "#{feed} error: #{get_blog_events.response_header.status}, header: #{get_blog_events.response_header}, response: #{get_blog_events.response}"
      end
    end

    def filter_old(feed_events)
      feed_events.each {|e| e['hash_key'] = Digest::MD5.hexdigest(e['link'] + self.feed)}
      super(feed_events)
    end

    def rename_attrs_in(new_events)
      new_events.map do |event| 
        self.class.prepare_event(event, {:feed => feed})
      end
    end

    def self.prepare_event(event, opts)
      # Blog RSS provides date in format: "07 Feb 2013"
      parsed_date = Time.strptime(event['published'], "%e %b %Y")
      ts = Time.utc(parsed_date.year, parsed_date.month, parsed_date.day, 0, 0, 1)
      
      {
        :meta => {
          :feed => opts[:feed],
        },
        :origin_ts => ts.iso8601,
        :origin_date => ts.strftime("%Y-%m-%d"),
        :title => event['title'],
        :body => Sanitize.clean(event['description'], Sanitize::Config::RELAXED),
        :url => event['link'],
        :hash_key => event['hash_key'],
        :source_data => event
      }
    end

  end
end
