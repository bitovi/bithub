require 'digest/md5'
require 'em-http-request'
require 'time'
require 'yajl'
require 'nokogiri'
require 'nori'

require_relative 'fetchers'
require 'app/domain/events/processor'
require 'app/domain/digest_queue'
require 'lib/loggable'

class Poller
  include Loggable
  #include Fetchers::Fake if %w(development test).include?(ENV['ENV'])
  #include Fetchers::HTTP if %w(testing staging production).include?(ENV['ENV'])
  include Fetchers::HTTP

  def self.handler(exchange, endpoint, &blk)
    new(exchange, endpoint, &blk).handler
  end

  def initialize(exchange, endpoint, &blk)
    initialize_logger
    @exchange = exchange
    @endpoint = endpoint
    @digest_queue = DigestQueue.new

    @config = {}
    blk.call(@config) if blk # relevant keys: :http_head, :term (forums)

    @feed ||= determine_feed(endpoint)
  end

  def handler
    lambda { fetch }
  end

  def fetch_next_page(http_req)
    if (link_header = http_req.response_header['LINK'])
      if (next_page_url = link_by_type(link_header, 'next').andand[:url])
        #log_fetching(next_page_url)
        fetch(next_page_url)
      end
    end
  end

  def link_by_type(link_header, type)
    parse_link_header(link_header).select{|l| l[:type] == type}.first
  end

  def parse_link_header(lh)
    # TODO select only links that have 'rel' attr
    lh.split(',').map do |rel|
      with_rel_attrs = pluck_pagination(rel)
      Hash[[:whole, :url, :type].zip with_rel_attrs]
    end
  end

  def pluck_pagination(rel)
    (rel.match /<(.*)>; rel="(.*)"/).to_a
  end

  def handle_success(response)
    decorated_events = processor(response).parse.extract.decorate
    publish(reject_old(decorated_events))
  end
  
  def reject_old(events)
    @digest_queue.reject_old(events)
  end

  def publish(events)
    begin
      log_publishing(events)
      pack_and_publish = lambda do
        events.each do |e|
          @exchange.publish(Yajl::Encoder.encode(e[:data]))
        end
      end
      EM.defer(pack_and_publish) if events.length > 0
    rescue Exception => e
      log_exception e
    end
  end

  def processor(response)
    Events::Processor.new(@feed, response) { @config[:processor_config] }
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

  def determine_feed(uri)
    f = %w(meetup github disqus blog forum).select{|f| uri =~ /#{f}/}
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
    @config[:http_head] || {}
  end

  def http_query
    @config[:http_query] || {}
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
end
