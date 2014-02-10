require 'digest/md5'
require 'em-twitter'

require 'events/processor'

class Streamer
  include Loggable

  class Configuration
    attr_accessor :user_stream, :connected_as
    def user_stream?; @user_stream; end
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
    initialize_logger("INFO")
    @exchange = exchange

    @config = Configuration.new
    blk.(@config) if blk

    @feed = 'twitter'
    @stream = EM::Twitter::Client.connect(stream_config)
  end

  def setup_handlers
    @stream.each do |result|
      handle_event(result)
    end

    @stream.on_error do |message|
      @logger.error "#{base_log_format} | error: #{message}"
    end

    # dynamically assign the rest of the errbacks
    ERRBACKS.each do |errback|
      @stream.send(errback.to_sym) do
        @logger.warn "#{base_log_format} | #{errback}"
      end
    end
  end

  def handle_event(event_json)
    event = processor(event_json).parse.extract.decorate.result
    publish(event)
  rescue Events::MappingError => err
    @logger.error "#{base_log_format} | #{err} | #{err.context} | #{event_json}"
  rescue Events::BuildingError=> err
    @logger.error "#{base_log_format} | #{err} | #{err.context} | #{event_json}"
  end

  def processor(response)
    Events::Processor.new(response) do |config| 
      config.feed = @feed
      config.user_stream = @config.user_stream?
    end
  end

  def publish(events)
    log_publishing(events)
    pack_and_publish = lambda do
      events.each do |e|
        @exchange.publish(Yajl::Encoder.encode(e))
      end
    end
    EM.defer(pack_and_publish) if events.length > 0
  end

  def log_publishing(event)
    @logger.info "#{base_log_format} | Publishing #{event.size} tweets"
    @logger.debug event.inspect
  end

  private

  def user
    @config.connected_as
  end

  def base_log_format
    "Feed: #{@feed} | User: @#{user}"
  end
end
