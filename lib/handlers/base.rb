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
      events_as_json = Yajl::Encoder.encode(events)
      @exchange.publish(events_as_json)
    end

    def handler
      proc do 
        fetch if initialized
      end
    end
  end
end
