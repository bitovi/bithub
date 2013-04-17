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
      forum_multi_fetch = EventMachine::MultiRequest.new
      @endpoints.each do |ep_name, ep|
        forum_multi_fetch.add(ep_name, EventMachine::HttpRequest.new(ep).get)
      end

      forum_multi_fetch.callback do
        if forum_multi_fetch.responses && forum_multi_fetch.responses[:callback]
          questions = @parser.parse(forum_multi_fetch.responses[:callback][:questions].response)['rss']['channel']['item']
          all = @parser.parse(forum_multi_fetch.responses[:callback][:all].response)['rss']['channel']['item']

          questions.each { |q| q['filter_term'] = 'question' }
          forum_events = all.concat(questions)

          new_events = filter_old forum_events
          events_to_store = rename_attrs_in new_events
          store(events_to_store) if events_to_store.size > 0

        elsif forum_multi_fetch.responses[:errback]
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
        self.class.prepare_event(event, {:feed => feed})
      end
    end

    def self.prepare_event(event, opts)
      # Zoho forums RSS provides time in format: "Sat, 23 Mar 2013 15:02:26 -0700"
      parsed_date = Time.parse(event['pubDate']).utc
      hash = { 
        :meta => {
          :origin_author_name => event['dc:creator'],
          :type => event['category'].snake_case,
          :category => event['filter_term'],
          :feed => opts[:feed],
        },
        :title => event['title'],
        :body => Sanitize.clean(event['description'], Sanitize::Config::RELAXED),
        :url => event['link'],
        :origin_ts => parsed_date.iso8601,
        :origin_date => parsed_date.strftime("%Y-%m-%d"),
        :hash_key => event['hash_key'],
        :source_data => event
      }
    end

  end
end
