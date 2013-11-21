require 'digest/md5'
require 'em-http-request'
require 'time'
require 'yajl'
require 'nokogiri'
require 'nori'

class Poller
  attr_reader :latest

  class UnknownFeedTypeException < Exception; end

  def self.handler(logger, exchange, endpoint, &blk)
    new(logger, exchange, endpoint, &blk).handler
  end

  def initialize(logger, exchange, endpoint, &blk)
    @logger = logger
    @exchange = exchange
    @endpoint = endpoint

    @config = {}

    blk.call(@config) if blk # relevant keys: :http_head, :term (forums)

    @feed ||= determine_feed(endpoint)
  end

  def handler
    lambda { fetch }
  end

  def fetch(link = nil)
    link = link || @endpoint

    http_req = EM::HttpRequest.new(link).get({
      query: http_query,
      head: http_head
    })

    http_req.callback do
      if success?(http_req)
        delay(1, lambda {fetch_next_page http_req}) if in_github_issues?
        handle_success(http_req)
      elsif client_error?(http_req)
        log_http_status(http_req, :error)
      elsif server_error?(http_req)
        log_http_status(http_req, :warn)
      else
        log_http_status(http_req, :error)
      end
    end

    http_req.errback do
      log_http_status(http_req, :error)
    end
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

  def handle_success(http_req)
    events = events_from_response(parse(http_req.response))
    publish(process(reject_old(events), feed_specific_config))
  end

  def reject_old(events)
    @latest ||= []

    new_events = events.reject do |e|
      e[:hash_key] = calc_hash_key(e)
      content_digest = processor.content_digest(e) || e[:hash_key]

      if @latest.include? content_digest
        true
      else
        @latest.push content_digest
        false         
      end
    end
        
    #log_filtering(events, new_events)

    @latest.shift(@latest.length - backlog_size) if @latest.length > backlog_size

    new_events
  end

  def process(events, fsc)
    begin
      events.map{|e| processor.process(e, fsc)}
    rescue Processor::InvalidEventException => e
      log_exception e
    end
  end

  def publish(events)
    begin
      log_publishing(events)
      pack_and_publish = lambda do
        events.each {|e| @exchange.publish(Yajl::Encoder.encode(e)) }
      end
      EM.defer(pack_and_publish) if events.length > 0
    rescue Exception => e
      log_exception e
    end
  end

  def calc_hash_key(event_hash)
    seed = processor.unique_attribute(event_hash) + @feed
    Digest::MD5.hexdigest(seed)
  end

  def events_from_response(response_hash)
    processor.events_from_response(response_hash)
  end

  def processor
    @processor ||= Processor.new(@feed)
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

  def parse(data)
    if json_feed?
      Yajl::Parser.parse(data)
    elsif rss_feed?
      @parser ||= Nori.new(:parser => :nokogiri)
      @parser.parse(data)
    else
      fail UnknownFeedTypeException, "can't determine if feed is JSON or XML"
    end
  end
  
  private

  def determine_feed(uri)
    f = %w(github disqus blog forum).select{|f| uri =~ /#{f}/}
    return (f[0] == "forum") ? "forums" : f.first
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
  
  def log_filtering(es, new_es)
    @logger.info "Keeping #{new_es.length} new items, out of #{es.length} fetched"
  end

  def log_fetching(url)
    @logger.info "Fetching from: #{url}"
  end

  def backlog_size
    @config[:backlog_size] || 100
  end

  def http_head
    @config[:http_head] || {}
  end
  
  def http_query
    @config[:http_query] || {}
  end

  def feed_specific_config
    @config[:feed_specific_config]
  end
  
  def json_feed?
    (@feed == 'github' || @feed == 'disqus')
  end

  def rss_feed?
    (@feed == 'forums' || @feed == 'blog')
  end

  def in_github_issues?
    (@feed.eql? 'github') && !!(@endpoint.match /issues/)
  end
end
