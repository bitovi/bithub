module Handler
  class Disqus < Base

    def fetch
      get_disqus_events = EM::HttpRequest.new('http://disqus.com/api/3.0/posts/list.json?api_key=NgGGShovTbuUwxX61HNZvHreDse9DXrW8zvqlJOUhn6BVKJFISuYACtjhZ17FFZB&forum[]=jmvcs3&forum[]=bitovi&related[]=thread&related[]=forum').get

      get_disqus_events.callback do
        disqus_events = Yajl::Parser.parse(get_disqus_events.response)['response']

        new_events = filter_old disqus_events
        events_to_store = rename_attrs_in new_events
        store(events_to_store) if events_to_store.size > 0
      end

      get_disqus_events.errback do
        @log.error "#{@feed} error: #{get_disqus_events.response_header.status}, header: #{get_disqus_events.response_header}, response: #{get_disqus_events.response}"
      end
    end

    def filter_old(feed_events)
      feed_events.each {|e| e['hash_key'] = Digest::MD5.hexdigest(e['id']+self.feed)}
      super(feed_events)
    end

    def rename_attrs_in(new_events)
      new_events.map do |event|
        { feed: feed,
          link: event['url'],
          actor: event['author']['name'],
          timestamp: event['createdAt'],
          body: event['message'],
          title: event['thread']['title'],
          hash_key: event['hash_key']
        # raw_data: Base64::encode64(event_json)
        }
      end
    end

  end
end
