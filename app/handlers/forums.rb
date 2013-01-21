module Handler
  class Forums < Base

    def fetch
      get_forum_events = EM::HttpRequest.new('http://forum.javascriptmvc.com/feed').get

      get_forum_events.callback do
        forum_events = Nori.parse(get_forum_events.response)['rss']['channel']['item']
        new_events = filter_old forum_events
        events_to_store = rename_attrs_in new_events
        store(events_to_store) if events_to_store.size > 0
      end

      get_forum_events.errback do
        @log.error "#{feed} error: #{get_forum_events.response_header.status}, header: #{get_forum_events.response_header}, response: #{get_forum_events.response}"
      end
    end

    def filter_old(feed_events)
      feed_events.each {|e| e['hash_key'] = Digest::MD5.hexdigest(e['link'] + self.feed)}
      super(feed_events)
    end

    def rename_attrs_in(new_events)
      new_events.map do |event| 
        raw_date = event['pubDate'].gsub(',','')
        # $log.info "RAW DATE: #{raw_date}"
        parsed_date = Time.strptime(raw_date, "%a %e %b %Y %T %z")
        # $log.info "PARSED DATE: #{parsed_date}"
        { actor: event['dc:creator'],
          title: event['title'],
          body: event['description'],
          link: event['link'],
          type: event['category'],
          timestamp: parsed_date.strftime("%FT%T%z"),
          feed: feed,
          hash_key: event['hash_key'],
          source_data: event
        }
      end
    end

  end
end
