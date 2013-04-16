require 'digest/md5'
require 'sanitize'
require 'rexml/document'

module Handler
  class Base
    attr_reader :initialized, :feed

    def self.handler(log, exchange)
      new(log, exchange).handler
    end

    def sanitize(html)
      Sanitize.clean(html, Sanitize::Config::RELAXED)
    end

    def initialize(log, exchange, backlog_size = 100)
      @parser = Nori.new(:parser => :nokogiri)
      @latest ||= []
      @feed = self.class.to_s.gsub('Handler::','').snake_case
      @log = log
      @exchange = exchange
      @backlog_size = backlog_size
    end

    def fetch
    end

    # Compare key with items already fetched and set the last batch of keys as latest
    def filter_old(feed_items)
      new_events = feed_items.reject {|e| @latest.include? e['hash_key']}
      @latest += new_events.collect {|e| e['hash_key']}
      if @latest.length > @backlog_size
        @latest.shift(@latest.length - @backlog_size)
      end
      new_events
    end

    def store(events)
      @log.info "#{@feed}: sending #{events.size} events"

      enqueue_events = proc do
        events.each { |e| @exchange.publish(Yajl::Encoder.encode(e), routing_key: "tasks.taggify") }
      end

      EM.defer(enqueue_events)
    end

    def handler
      proc { fetch }
    end
  end
end
