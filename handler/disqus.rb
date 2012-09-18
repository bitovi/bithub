module Handler
  class Disqus < Base

    # TODO
    # def bootstrap
    # end

    def fetch
      disqus_events = HttpRequest.new('http://disqus.com/api/3.0/posts/list.json?api_key=NgGGShovTbuUwxX61HNZvHreDse9DXrW8zvqlJOUhn6BVKJFISuYACtjhZ17FFZB&forum[]=jmvcs3&forum[]=bitovi&related[]=thread&related[]=forum').get


      disqus_events.callback do
        events_hash = Yajl::Parser.parse(disqus_events.response)['response']

        ids = events_hash.collect {|e| e['id']}
        new_events = events_hash.reject {|e| @latest.include? e['id']}
        @latest = ids
        
        events = new_events.collect do |event|
          { raw_data: Base64::encode64(Yajl::Encoder.encode(event)),
            feed: 'disqus',
            link: event['url'],
            username: event['author']['name'],
            timestamp: event['createdAt'],
            body: event['message'],
            title: event['thread']['title']
          }
        end

        if new_events.size > 0
          @log.info "#{feed}: #{events.size} new events"
          store(events)
        else
          @log.info "#{feed}: Nothing new"
        end
      end

      disqus_events.errback do
        @log.error "#{@feed} error: #{disqus_events.response_header.status}, header: #{disqus_events.response_header}, response: #{disqus_events.response}"
      end
    end

  end
end
