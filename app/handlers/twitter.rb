require 'digest/md5'
require 'em-http-request'
require 'em-twitter'

module Handler
  class Twitter
    attr_reader :initialized, :feed

    ERRBACKS = [ "on_unauthorized", "on_forbidden",
      "on_not_found", "on_not_acceptable",
      "on_too_long", "on_no_data_received",
      "on_close", "on_max_reconnects",
      "on_enhance_your_calm", "on_service_unavailable", 
      "on_range_unacceptable", "on_reconnect"
    ]

    def self.connect(log, exchange, stream_auth_and_opts)
      self.new(log, exchange, stream_auth_and_opts).connect
    end

    def initialize(log, exchange, stream_auth_and_opts)
      @log = log
      @initialized ||= true
      @exchange = exchange
      @feed = self.class.to_s.gsub('Handler::','').underscore.downcase
      @stream_auth_and_opts = stream_auth_and_opts
    end

    def connect
      @stream = EM::Twitter::Client.connect(@stream_auth_and_opts)

      @stream.each do |result|
        @log.info result
        handle_event(result)
      end

      @stream.on_error do |message|
        @log.error "#{@stream} ERROR: #{message}"
      end

      # dynamically assign the rest of the errbacks
      ERRBACKS.each do |errback|
        @stream.send(errback.to_sym) do
          @log.error "#{@stream} somethin happen: #{errback}"
        end
      end
    end

    def handle_event(raw_json)
      event = Yajl::Parser.parse(raw_json)

      if event['created_at']
        parsed_date = Time.strptime(event['created_at'], "%a %b %d %T %z %Y")
      else
        parsed_date = Time.now
      end

      hash = {
        feed: feed,
        source_data: event,
        timestamp: parsed_date.strftime("%FT%T%z"),
      }

      if event['event'] == 'follow' && event['target']['screen_name']
        hash['actor'] = event['source']['screen_name']
        hash['actor_id'] = event['source']['id_str']
        hash['type'] = 'follow_event'
        hash['title'] = "followed @#{event['target']['screen_name']}"
        hash['hash_key'] = Digest::MD5.hexdigest(event['source']['id_str'] + event['target']['id_str'] + feed) # actor's id + target's id + feed

      elsif event['user']
        hash['actor'] = event['user']['screen_name']
        hash['actor_id'] = event['user']['id_str']
        hash['source_id'] = event['id_str']
        hash['type'] = 'status_event'
        hash['link'] = "https://twitter.com/#{event['user']['screen_name']}/status/#{event['id_str']}"
        hash['title'] = event['text']
        hash['hash_key'] = Digest::MD5.hexdigest(event['id_str'] + feed) #event's id + feed
      end

      enqueue_events = proc do
        @exchange.publish(Yajl::Encoder.encode(hash), routing_key: "tasks.taggify")
      end

      # Sending (network IO) in a separate lightweight process so we don't block the reactor loop 
      EM.defer(enqueue_events)
    end

  end #Class
end #Module
