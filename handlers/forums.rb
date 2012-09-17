module Handler
  class Forums < Base

    # TODO
    # def bootstrap
    # end

    def fetch
      forum_events = HttpRequest.new('http://forum.javascriptmvc.com/feed').get

      forum_events.callback do
        feed_items = Nori.parse(forum_events.response)['rss']['channel']['item']

        links = feed_items.collect {|e| e['link']}
        new_events = feed_items.reject {|e| @latest.include? e['link']}
        @latest = links
        

        events = new_events.collect do |event| 
          { title: event['title'],
            link: event['link'],
            username: event['dc:creator'],
            timestamp: event['pubDate'],
            feed: 'forums'
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
