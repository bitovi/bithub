module Handler
  class CommunitySite < Base

    def fetch
      get_community_site_events = EM::HttpRequest.new('http://community.javascriptmvc.com/posts.rss').get

      get_community_site_events.callback do
        community_site_events = @parser.parse(get_community_site_events.response)['rss']['channel']['item']
        new_events = filter_old community_site_events
        events_to_store = rename_attrs_in new_events
        store(events_to_store) if events_to_store.size > 0
      end

      get_community_site_events.errback do
        @log.error "#{feed} error: #{get_community_site_events.response_header.status}, header: #{get_community_site_events.response_header}, response: #{get_community_site_events.response}"
      end
    end

    def filter_old(feed_events)
      feed_events.each {|e| e['hash_key'] = Digest::MD5.hexdigest(e['link']+self.feed)}
      super(feed_events)
    end

    def rename_attrs_in(new_events)
      new_events.map do |event| 
        raw_date = event['pubDate'].gsub(',','')
        # $log.info "RAW DATE: #{raw_date}"
        parsed_date = Time.strptime(raw_date, "%a %e %b %Y %T %z")
        # $log.info "PARSED DATE: #{parsed_date}"

        { actor: event['author'],
          title: event['title'],
          body: event['description'],
          link: event['link'],
          created_ts: parsed_date.strftime("%FT%T%z"),
          feed: feed,
          source_data: event,
          hash_key: event['hash_key']
        }
      end
    end

  end
end
