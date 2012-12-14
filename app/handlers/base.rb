require 'digest/md5'

module Handler
  class Base
    attr_reader :initialized, :feed

    def self.handler(log, exchange)
      self.new(log, exchange).handler
    end

    def initialize(log, exchange)
      @latest ||= []
      @initialized ||= false
      @feed = self.class.to_s.gsub('Handler::','').underscore.downcase
      @log = log
      @exchange = exchange
      bootstrap('hash_key')
    end

    def fetch
    end

    # Compare key with items already fetched and set the last batch of keys as latest
    def filter_old(feed_items)
      new_events = feed_items.reject {|e| @latest.include? e['hash_key']}
      @latest = feed_items.collect {|e| e['hash_key']}
      new_events
    end

    def store(events)
      @log.info "#{@feed}: sending #{events.size} events"

      enqueue_events = proc do
        events.each { |e| @exchange.publish(Yajl::Encoder.encode(e), routing_key: "tasks.taggify") }
      end

      # Sending (network IO) in a separate lightweight process
      # so that the reactor loop can continue
      EM.defer(enqueue_events)
    end

    def bootstrap(qualifier)
      request_string = "#{ENV['FEEDER_WEB']}/hashes?feed=#{@feed}&items=50"
      $log.info "REQ STR: " + request_string

      get_latest = EM::HttpRequest.new(request_string).get
      get_latest.callback do
        @latest = Yajl::Parser.parse(get_latest.response)
        @log.info "#{feed}: #{@latest}"
        @initialized = true
      end
    end

    def handler
      proc do 
        if @initialized
          fetch
        else
          bootstrap('hash_key')
          @log.info "#{feed}: Initiaizing..."
        end
      end
    end
  end
end
