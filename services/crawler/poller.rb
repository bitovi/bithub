require 'digest/md5'
require 'em-http-request'
require 'time'
require 'yajl'
require 'nokogiri'
require 'nori'

require 'events/processor'
require 'digest_queue'

require_relative 'extensions/bootable'
require_relative 'extensions/fakeable'
require_relative 'extensions/pageable'

class Poller
  include Loggable

  class Configuration
    attr_accessor :http_query, :http_head,
      :digest_queue_config,
      :processor_config
  end

  def initialize(exchange, endpoint, &blk)
    initialize_logger("INFO")
    @config = Configuration.new
    blk.(@config) if blk

    @exchange = exchange
    @endpoint = endpoint

    @digest_queue = DigestQueue.new([], @config.digest_queue_config || {})
    @feed ||= determine_feed(endpoint)
  end

  def handler
    if bootable?
      lambda { booted? ? fetch : delay(1, lambda {boot}) }
    else
      lambda { fetch }
    end
  end

  def fetch(link = nil)
    link = link || @endpoint

    http_req = EM::HttpRequest.new(link).get({
      query: http_query,
      head: http_head
    })

    log_fetching(link)

    http_req.callback { callback(http_req) }
    http_req.errback { errback(http_req) }

  end

  def callback(http_req)
    if success?(http_req)
      delay(1, lambda {next_page(http_req)}) if pageable?
      handle_success(http_req.response)
    else
      handle_errors(http_req)
    end
  end

  def errback(http_req)
    log_http_status(http_req, :error)
  end

  def handle_success(http_resp)
    processed = processor(http_resp).parse.extract.decorate.result
    publish(reject_old(processed))
  rescue Events::DispatchError => err
    @logger.error "Feed #{@feed} | #{err} | #{err.context}"
  rescue Events::BuildingError=> err
    @logger.error "Feed #{@feed} | #{err} | #{err.context}"
  end

  def handle_errors(http_req)
    if client_error?(http_req)
      log_http_status(http_req, :error)
    elsif server_error?(http_req)
      log_http_status(http_req, :warn)
    else
      log_http_status(http_req, :error)
    end
  end

  def processor(response)
    Events::Processor.new(response) do |config|
      config.feed = @feed
      config.term = @config.processor_config[:term] if @config.processor_config
    end
  end

  def reject_old(events)
    @digest_queue.reject_old(events)
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

  def success?(http_resp)
    http_resp.response_header.status.to_s =~ /2../
  end

  def client_error?(http_resp)
    http_resp.response_header.status.to_s =~ /4../
  end

  def server_error?(http_resp)
    http_resp.response_header.status.to_s =~ /5../
  end

  def delay(t, fn)
    EM.add_timer(t, &fn)
  end

  private

  # --- Roles

  def pageable?
    self.respond_to? 'next_page'
  end

  def bootable?
    self.is_a? Bootable
  end

  # --- /Roles


  def determine_feed(uri)
    f = %w(meetup twitter github disqus blog forum).select{|f| uri =~ /#{f}/}
    f.first
  end

  def log_exception(e)
    @logger.error "ENDPOINT: #{@endpoint} | MESSAGE: #{e.message}"
  end

  def log_http_status(resp, level)
    @logger.send(level, "ENDPOINT: #{@endpoint} | STATUS: #{resp.response_header.status}")
    @logger.error "... MESSAGE: #{resp.error}" if resp.error
  end

  def log_publishing(es)
    str = "Publishing #{es.length} items from #{@endpoint}"
    str += " for #{http_query[:state]} issues" if in_github_issues?
    @logger.info str if es.length > 0
  end

  def log_fetching(url)
    @logger.info "Fetching from: #{url}"
  end

  def http_head
    @config.http_head || {}
  end

  def http_query
    @config.http_query || {}
  end

  def json_feed?
    (@feed == 'github' || @feed == 'disqus' || @feed == 'meetup')
  end

  def rss_feed?
    (@feed == 'forums' || @feed == 'blog')
  end

  def in_github_issues?
    (@feed.eql? 'github') && !!(@endpoint.match /issues/)
  end

  def count_not_empty(events)
    events.reject{|e| e.empty?}.count
  end

end
