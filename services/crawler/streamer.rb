require 'digest/md5'
require 'em-twitter'

require 'app/domain/events/processor'

class Streamer
  attr_reader :feed, :processor, :connected_as

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
    @logger = log
    @feed = 'twitter'
    @exchange = exchange
    @stream_auth_and_opts = stream_auth_and_opts
    @connected_as = stream_auth_and_opts[:oauth][:consumer_key] || "no consumer key!!!"
    @processor = Events::Processor.new(@feed) {|c| c[:user_stream_flag] = is_user_stream }
  end

  def connect
    @stream = EM::Twitter::Client.connect(@stream_auth_and_opts)

    @stream.each do |result|
      handle_event(result)
    end

    @stream.on_error do |message|
      @logger.error "#{@stream} connected as #{@connected_as} ERROR: #{message}"
    end

    # dynamically assign the rest of the errbacks
    ERRBACKS.each do |errback|
      @stream.send(errback.to_sym) do
        @logger.error "#{@stream} connected as #{@connected_as} somethin happen: #{errback}"
      end
    end
  end

  def handle_event(raw_json)
    event = Yajl::Parser.parse(raw_json)
    begin
      publish(processor.process(event))
    rescue Events::Errors::InvalidEventException => e
      if event["friends"]
        @logger.info "FEED: #{feed} | AS: #{connected_as} | #{e} | Skipping friends list event"
      else
        @logger.error "FEED: #{feed} | AS: #{connected_as} | #{e} | #{event}"
      end
    rescue => error
      @logger.error "FEED: #{feed} | AS: #{connected_as} | #{error}"
    end
  end

  def publish(event)
    #log_publishing
    EM.defer do 
      @exchange.publish(Yajl::Encoder.encode(event))
    end
  end

  def log_publishing
    str = "Publishing from Twitter"
    @logger.info str
  end

end
