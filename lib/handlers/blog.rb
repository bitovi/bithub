module Handler
  class Blog < Base

    def fetch
      blog_events = EM::HttpRequest.new('http://www.bitovi.com/blog.rss').get

      blog_events.callback do
        feed_items = Nori.parse(blog_events.response)['rss']['channel']['item']

        links = feed_items.collect {|e| e['link']}
        new_events = feed_items.reject {|e| @latest.include? e['link']}
        @latest = links
        
        events = new_events.collect do |event| 
          { timestamp: event['published'],
            title: event['title'],
            link: event['link'],
            feed: 'blog',
            hash_key: Digest::MD5.hexdigest(event['link'])
            # raw_data: Base64::encode64(event_json)
          }
        end

        store(events) if events.size > 0
      end

      blog_events.errback do
        @log.error "Error: #{blog_events.response_header.status}, header: #{blog_events.response_header}, response: #{blog_events.response}"
      end

    end
  end
end
