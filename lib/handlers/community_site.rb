module Handler
  class CommunitySite < Base

    def fetch
      forum_events = EM::HttpRequest.new('http://community.javascriptmvc.com/posts.rss').get

      forum_events.callback do
        feed_items = Nori.parse(forum_events.response)['rss']['channel']['item']

        links = feed_items.collect {|e| e['link']}
        new_events = feed_items.reject {|e| @latest.include? e['link']}
        @latest = links
        
        events = new_events.collect do |event| 
          { title: event['title'],
            link: event['link'],
            timestamp: event['pubDate'],
            feed: 'community_site',
            hash_key: Digest::MD5.hexdigest(event['link'])
            # raw_data: Base64::encode64(event_json)
          }
        end

        store(events) if events.size > 0
      end

      forum_events.errback do
        @log.error "Error: #{forum_events.response_header.status}, header: #{forum_events.response_header}, response: #{forum_events.response}"
      end
    end
  end
end
