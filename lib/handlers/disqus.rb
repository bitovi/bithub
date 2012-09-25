module Handler
  class Disqus < Base

    def fetch
      disqus_events = EM::HttpRequest.new('http://disqus.com/api/3.0/posts/list.json?api_key=NgGGShovTbuUwxX61HNZvHreDse9DXrW8zvqlJOUhn6BVKJFISuYACtjhZ17FFZB&forum[]=jmvcs3&forum[]=bitovi&related[]=thread&related[]=forum').get

      disqus_events.callback do
        events_hash = Yajl::Parser.parse(disqus_events.response)['response']

        ids = events_hash.collect {|e| e['id']}
        new_events = events_hash.reject {|e| @latest.include? e['id']}
        @latest = ids
        
        events = new_events.collect do |event|
          feed = 'disqus'
          { feed: feed,
            link: event['url'],
            actor: event['author']['name'],
            timestamp: event['createdAt'],
            body: event['message'],
            title: event['thread']['title'],
            hash_key: Digest::MD5.hexdigest(event['id']+feed)
            # raw_data: Base64::encode64(event_json)
          }
        end

        store(events) if events.size > 0
      end

      disqus_events.errback do
        @log.error "#{@feed} error: #{disqus_events.response_header.status}, header: #{disqus_events.response_header}, response: #{disqus_events.response}"
      end
    end

  end
end
