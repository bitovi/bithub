require 'digest/md5'
require 'em-http-request'
require 'em-twitter'
require 'app/processors/twitter/processor'

module Handler
  class Twitter
    attr_reader :feed, :processor

    ERRBACKS = [
      "on_unauthorized", "on_forbidden",
      "on_not_found", "on_not_acceptable",
      "on_too_long", "on_no_data_received",
      "on_close", "on_max_reconnects",
      "on_enhance_your_calm", "on_service_unavailable", 
      "on_range_unacceptable", "on_reconnect"
    ]

    def self.connect(log, exchange, stream_auth_and_opts, is_user_stream)
      self.new(log, exchange, stream_auth_and_opts, is_user_stream).connect
    end

    def initialize(log, exchange, stream_auth_and_opts, is_user_stream)
      @log = log
      @exchange = exchange
      @stream_auth_and_opts = stream_auth_and_opts
      @connected_as = stream_auth_and_opts[:oauth][:consumer_key] || "no consumer key!!!"

      @feed = self.class.to_s.gsub('Handler::','').snake_case
      @processor = EventProcessor::Twitter.new({feed: @feed, is_user_stream: is_user_stream})
    end

    def connect
      @stream = EM::Twitter::Client.connect(@stream_auth_and_opts)

      @stream.each do |result|
        handle_event(result)
      end

      @stream.on_error do |message|
        @log.error "#{@stream} connected as #{@connected_as} ERROR: #{message}"
      end


      # dynamically assign the rest of the errbacks
      ERRBACKS.each do |errback|
        @stream.send(errback.to_sym) do
          @log.error "#{@stream} connected as #{@connected_as} somethin happen: #{errback}"
        end
      end
    end

    def handle_event(raw_json)
      event = Yajl::Parser.parse(raw_json)
      begin
        publish processor.process(event)
      rescue EventProcessor::Twitter::NotValidEventException => e
        @log.error "FEED: #{feed} | #{e}"
      rescue => error
        @log.error "FEED: #{feed} | ERROR: #{error}"
      end
    end

    def publish(event)
      enqueue_events = proc do
        @exchange.publish(Yajl::Encoder.encode(event), routing_key: "tasks.taggify")
      end
      EM.defer(enqueue_events)
    end

  end
end
