module Handler
  class Base
    attr_reader :initialized, :feed

    def self.handler(log, url)
      self.new(log, url).handler
    end

    def initialize(log, storer_url)
      @latest = []
      @feed = self.class.to_s.gsub('Handler::','')
      @log = log
      @initialized = true
      @storer_url = storer_url
      # bootstrap
    end

    def bootstrap
      initialized = true
    end

    def store(events)
      events_as_json = Yajl::Encoder.encode(events)
      store_events = EventMachine::HttpRequest.new(@storer_url).post(body: { events: events_as_json })

      store_events.errback do
        @log.error "Error: #{store_events.response_header.status}, header: #{store_events.response_header}, response: #{store_events.response}"
      end

      store_events.callback do
        @log.info "#{feed}: #{events.size} events stored"
      end

      
    end

    def handler
      proc do 
        fetch if initialized
      end
    end
  end
end
