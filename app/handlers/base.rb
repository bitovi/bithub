require 'digest/md5'
require 'sanitize'

module Handler
  class Base
    attr_reader :initialized, :feed

    def self.handler(log, exchange)
      new(log, exchange).handler
    end

    def sanitize(html)
      Sanitize.clean(html, Sanitize::Config::RELAXED)
    end

    def initialize(log, exchange)
      @parser = Nori.new(:parser => :nokogiri)
      @latest ||= []
      @initialized ||= false
      @feed = self.class.to_s.gsub('Handler::','').snake_case
      @log = log
      @exchange = exchange
    end

    def fetch
    end

    # Compare key with items already fetched and set the last batch of keys as latest
    def filter_old(feed_items)
      new_events = feed_items.reject {|e| @latest.include? e['hash_key']}
      @latest += feed_items.collect {|e| e['hash_key']}
      if @latest.length > 1000
        diff = @latest.length - 1000
        @latest.shift(diff)
      end
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

    def handler
      proc do 
        if @initialized
          fetch
        else
          @initialized = true
          @log.info "#{feed}: Initiaizing..."
        end
      end
    end
  end
end
