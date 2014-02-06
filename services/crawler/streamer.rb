require 'digest/md5'
require 'em-twitter'

require 'events/processor'

class Streamer
  include Loggable
  attr_reader :feed, :processor, :connected_as

  class Configuration
    attr_accessor :is_user_stream
  end

  ERRBACKS = [
    "on_unauthorized", "on_forbidden",
    "on_not_found", "on_not_acceptable",
    "on_too_long", "on_no_data_received",
    "on_close", "on_max_reconnects",
    "on_enhance_your_calm", "on_service_unavailable", 
    "on_range_unacceptable", "on_reconnect",
  ]

  def self.connect(exchange, stream_config, &blk)
    self.new(exchange, stream_config, &blk).setup_handlers
  end

  def initialize(exchange, stream_config, &blk)
    initialize_logger("ERROR")
    @exchange = exchange

    @config = OpenStruct.new
    blk.(@config) if blk

    @connected_as = stream_config[:oauth][:consumer_key] || "no consumer key!!!"
    @feed = 'twitter'
    @stream = EM::Twitter::Client.connect(stream_config)
  end

  def setup_handlers
    @stream.each do |result|
      handle_event(result)
    end

    @stream.on_error do |message|
      @logger.error "#{@stream} connected as #{@connected_as} ERROR: #{message}"
    end

    # dynamically assign the rest of the errbacks
    ERRBACKS.each do |errback|
      @stream.send(errback.to_sym) do
        @logger.warn "#{@stream} connected as #{@connected_as} somethin happen: #{errback}"
      end
    end
  end

  def handle_event(event_json)
    begin
      if (event = processor(event_json).parse.extract.decorate.result)
        publish(event)
      end
    rescue Events::MappingError => e
      @logger.error "FEED: #{feed} | AS: #{connected_as} | #{e} | #{event_json}"
    end
  end

  def processor(response)
    Events::Processor.new(response) do |config| 
      config.feed = @feed
      config.is_user_stream = @config.is_user_stream
    end
  end

  def publish(event)
    EM.defer do 
      @exchange.publish(Yajl::Encoder.encode(event))
    end
  end

  def log_publishing
    str = "Publishing from Twitter"
    @logger.info str
  end
end
