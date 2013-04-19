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

    def self.connect(log, exchange, stream_auth_and_opts, is_user_stream)
      self.new(log, exchange, stream_auth_and_opts, is_user_stream).connect
    end

    def initialize(log, exchange, stream_auth_and_opts, is_user_stream)
      @log = log
      @initialized ||= true
      @exchange = exchange
      @feed = self.class.to_s.gsub('Handler::','').snake_case
      @stream_auth_and_opts = stream_auth_and_opts
      @is_user_stream = is_user_stream
      @connected_as = stream_auth_and_opts[:oauth][:consumer_key] || "no consumer key!!!"
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
        if @is_user_stream && event['event'] == 'follow' && event['target']['screen_name']
          @log.info "follow_event: #{event['source']['screen_name']} followed #{event['target']['screen_name']}"
          handle_user_stream_event(event)
        elsif !@is_user_stream
          @log.info "new PUBLIC STREAM tweet: #{event}"
          handle_public_stream_event(event)
        end
      rescue NoMethodError => error
        @log.error "#{self.feed} ERROR: #{error}"
      end
    end

    def handle_user_stream_event(event)
      parsed_date =  parse_date(event)

      event_hash = {
        :meta => {
          :origin_author_name => event['source']['screen_name'],
          :origin_author_id => event['source']['id'],
          :type => 'follow_event',
          :feed => feed
        },
        :title => "followed @#{event['target']['screen_name']}",
        :hash_key => Digest::MD5.hexdigest(event['source']['id_str'] + event['target']['id_str'] + feed),
        :origin_ts => parsed_date.iso8601,
        :origin_date => parsed_date.strftime("%Y-%m-%d"),
        :source_data => event
      }
      publish(event_hash)
    end

    def handle_public_stream_event(event)
      parsed_date =  parse_date(event)

      event_hash = {
        :meta => {
          :origin_author_name => event['user']['screen_name'],
          :origin_author_id => event['user']['id'],
          :origin_id => event['id'],
          :type => 'status_event',
          :feed => feed,
          :tweet_id => event['id_str']
        },
        :title => event['text'],
        :url => "https://twitter.com/#{event['user']['screen_name']}/status/#{event['id_str']}",
        :origin_ts => parsed_date.iso8601,
        :origin_date => parsed_date.strftime("%Y-%m-%d"),
        :hash_key => Digest::MD5.hexdigest(event['id_str'] + feed),
        :source_data => event,
      }

      # add original tweet id -> used later for grouping retweets
      if event['retweeted_status']
        event_hash[:meta][:retweeted_id] = event['retweeted_status']['id_str']
      end

      publish(event_hash)
    end

    def parse_date(event)
      if event['created_at']
        # Twitter provides date in format: "Tue Jan 29 20:55:35 +0000 2013"
        parsed_date = Time.strptime(event['created_at']).utc # "%a %b %d %T %z %Y"
        # http://ruby-doc.org/stdlib-1.9.3/libdoc/time/rdoc/Time.html#method-c-iso8601
      else
        parsed_date = Time.now
      end
      parsed_date
    end

    def publish(event)
      enqueue_events = proc do
        @exchange.publish(Yajl::Encoder.encode(event), routing_key: "tasks.taggify")
      end
      # Sending (network IO) in a separate lightweight process so we don't block the reactor loop 
      EM.defer(enqueue_events)
    end

  end #Class
end #Module
