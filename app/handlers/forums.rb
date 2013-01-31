module Handler
  class Forums < Base

    ## Possible endpoints
    # https://forum.javascriptmvc.com/feed/filter/questions
    # https://forum.javascriptmvc.com/feed/filter/ideas
    
    def self.handler(log, exchange, endpoints)
      new(log, exchange, endpoints).handler
    end

    def initialize(log, exchange, endpoints)
      @endpoints = endpoints
      super(log,exchange)
    end


    def fetch
      @log.info "Fetching..."
      forum_multi_fetch = EventMachine::MultiRequest.new
      @endpoints.each do |ep_name, ep|
        forum_multi_fetch.add(ep_name, EventMachine::HttpRequest.new(ep).get)
      end

      forum_multi_fetch.callback do
        questions = @parser.parse(forum_multi_fetch.responses[:callback][:questions].response)['rss']['channel']['item']
        all = @parser.parse(forum_multi_fetch.responses[:callback][:all].response)['rss']['channel']['item']

        questions.each { |q| q['filter_term'] = 'question' }
        forum_events = all.concat(questions)

        new_events = filter_old forum_events
        events_to_store = rename_attrs_in new_events
        store(events_to_store) if events_to_store.size > 0

        if forum_multi_fetch.responses[:errback]
          forum_multi_fetch.responses[:errback].each do |r|
            @log.error "#{feed} ERROR: #{r.status}, header: #{r.response_header}"
          end
        end
      end

    end

    def filter_old(feed_events)
      feed_events.each {|e| e['hash_key'] = Digest::MD5.hexdigest(e['link'] + self.feed)}
      super(feed_events)
    end

    def rename_attrs_in(new_events)
      new_events.map do |event| 
        raw_date = event['pubDate'].gsub(',','')
        parsed_date = Time.strptime(raw_date, "%a %e %b %Y %T %z")
        hash = { actor: event['dc:creator'],
          title: event['title'],
          body: event['description'],
          link: event['link'],
          type: event['category'],
          filter_term: event['filter_term'],
          created_ts: parsed_date.strftime("%FT%T%z"),
          feed: feed,
          hash_key: event['hash_key'],
          source_data: event
        }
        @log.info hash
        return hash
      end
    end

  end
end
