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
        # $log.info "RAW DATE: \"#{event['published']}\""
        parsed_date = Time.strptime(event['published'], "%e %b %Y")
        # $log.info "PARSED DATE: #{parsed_date}"
        {
          props: {
            feed: feed,
          },
          origin_ts: parsed_date.strftime("%FT%T%z"),
          title: event['title'],
          body: event['description'],
          url: event['link'],
          hash_key: event['hash_key'],
          raw_json: event
        }
      end
    end

  end
end
