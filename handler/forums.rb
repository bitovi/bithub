module Handler
  class Forums < Base

    def fetch
      forum_events = HttpRequest.new('http://forum.javascriptmvc.com/feed').get

      forum_events.callback do
        feed_items = Nori.parse(forum_events.response)['rss']['channel']['item']

        links = feed_items.collect {|e| e['link']}
        new_events = feed_items.reject {|e| @latest.include? e['link']}
        @latest = links
        

        events = new_events.collect do |event| 
          # event_json = Yajl::Encoder.encode(event)
          { title: event['title'],
            link: event['link'],
            username: event['dc:creator'],
            timestamp: event['pubDate'],
            feed: 'forums',
            hash_key: Digest::MD5.hexdigest(event['link'])
            # raw_data: Base64::encode64(event_json)
          }
        end
        
        if new_events.size > 0
          @log.info "#{feed}: #{events.size} new events"
          store(events)
        else
          @log.info "#{feed}: Nothing new"
        end
      end

      forum_events.errback do
        @log.error "Error: #{forum_events.response_header.status}, header: #{forum_events.response_header}, response: #{forum_events.response}"
      end
    end
  end
end

#
## EVENT DEFINITION
#
# title: item.title
# link: item.link
# username: item.dc:createor
#   link?
# timestamp: item.pubDate
