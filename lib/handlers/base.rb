require 'digest/md5'

module Handler
  class Base
    attr_reader :initialized, :feed

    def self.handler(log, url)
      self.new(log, url).handler
    end

    def initialize(log, exchange)
      @latest = []
      @feed = self.class.to_s.gsub('Handler::','')
      @log = log
      @initialized = true
      @exchange = exchange
      # bootstrap
    end

    def bootstrap
      initialized = true
    end

    def store(events)
      @log.info "#{@feed}: sending #{events.size} events"

      enqueue_events = proc do
        events.each { |e| @exchange.publish(Yajl::Encoder.encode(e)) }
      end

      # Sending (network IO) in a separate lightweight process
      # so that the reactor loop can continue
      EM.defer(enqueue_events)
    end

    def handler
      proc do 
        fetch if initialized
      end
    end
  end
end
