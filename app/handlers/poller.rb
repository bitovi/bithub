require 'digest/md5'
require 'sanitize'
require 'htmlentities'
require 'rexml/document'
require 'em-http-request'
require 'time'

class Poller
  attr_reader :latest
  attr_accessor :backlog_size, :http_head, :feed, :api_key

  CUSTOM_RULESET = Sanitize::Config::RELAXED
  CUSTOM_RULESET[:elements] << "div"

  def self.handler(logger, exchange, endpoint, &blk)
    new(logger, exchange, endpoint, &blk).handler
  end

  def initialize(logger, exchange, endpoint, &blk)
    @logger = logger
    @exchange = exchange
    @endpoint = endpoint

    blk.call(self) if blk # relevant keys: :head, :feed, :api_key ?

    @backlog_size ||= 100
    @http_head ||= {}
    @feed ||= determine_feed(endpoint)
  end

  def handler
    lambda { fetch }
  end

  def fetch(link = nil, query = {})
    link = link || @endpoint

    http_req = EM::HttpRequest.new(link).get({
      query: query,
      head: @http_head
    })

    # TODO za forums :  questions.each { |q| q['filter_term'] = 'question' } -> meta[:category] = filter_term u processoru

    http_req.callback do
      if success?(http_req)
        delay(1, lambda {fetch_next_page http_req}) if in_github_issues?
        handle_success(http_req)
      elsif error?(http_req)
        handle_error(http_req)
      else
        log_http_status(http_req)
      end
    end

    http_req.errback do
      @logger.error "ENDPOINT: #{endpoint} | Mysterious error #{http_req.error}"
    end
  end
  
  def fetch_next_page(http_req)
    if (link_header = http_req.response_header['LINK'])
      if (next_page_query_params = only_query_params(link_by_type(link_header, 'next')))
        logger.info "Fetching next page: #{next_page_query_params}"
        fetch(next_page_query_params)
      end
    end
  end

  def link_by_type(link_header, type)
    parse_link_header(link_header).select{|l| link[:type] == type}.first
  end
    
  def parse_link_header(lh)
    # TODO add filtering for 'rel' type links only
    lh.split(',').map {|rel| [:link, :url, :type].zip(pluck_pagination(rel))}
  end
  
  def pluck_pagination(rel)
    /<(.*)>; rel="(.*)"/.match(rel).to_a
  end

  def handle_success(http_req, &parse)
    events = parser.parse(http_req.response)

    key_maker = lambda do |e|
      seed = pluck_unique_attribute(e) + @config[:feed]
      e[:hash_key] = Digest::MD5.hexdigest(seed)
    end
    
    publish(process(reject_old(events, &key_maker)))
  end

  def reject_old(events, key_maker = nil)
    @latest ||= []

    new_events = events
      .each {|i| key_maker[i] if i[:hash_key].nil?}
      .reject {|e| @latest.include? e[:hash_key]}

    @latest += new_events.map {|e| e[:hash_key]}
    if @latest.length > @backlog_size
      @latest.shift(@latest.length - @backlog_size)
    end
    new_events
  end

  def process(events)
    begin
      events.map{|e| @processor.process(e)}
    rescue Processor::NotValidEventException => e
      log_exception e
    end
  end

  def publish(events)
    begin
      pack_and_publish = lambda { @exchange.publish(Yajl::Encoder.encode(events)) }
      EM.defer(pack_and_publish) if events.length > 0
    rescue Exception => e
      log_exception e
    end
  end

  def handle_error(resp)
    log_http_status(resp)
  end

  def sanitize(html)
    decode(cleanup(encode(html)))
  end

  def encode(text)
    @htmlEscaper ||= HTMLEntities.new
    @htmlEscaper.encode(text)
  end

  def decode(text)
    @htmlEscaper ||= HTMLEntities.new
    @htmlEscaper.decode(text)
  end

  def cleanup(text)
    Sanitize.clean(@htmlEscaper.encode(text), CUSTOM_RULESET)
  end

  def success?(http_resp)
    http_resp.response_header.status.to_s =~ /2../
  end

  def error?(http_resp)
    (http_resp.response_header.status.to_s =~ /4../) || (http_resp.response_header.status.to_s =~ /5../)
  end

  def delay(t, fn)
    EM.add_timer(t, &fn)
  end

  def parser
    if in_github? || in_disqus?
      @parser ||= Yajl::Parser.new
    elsif in_forums? || in_blog?
      @parser ||= Nori.new(:parser => :nokogiri)
    end
  end

  def pluck_unique_attribute(event_hash)
    if in_github? || in_disqus?
      (event_hash[:id] || event_hash['id']).to_s
    elsif in_forums? || in_blog?
      (event_hash[:link] || event_hash['link'])
    end
  end
    
  def log_exception(e)
    @logger.error "ENDPOINT: #{@endpoint} | MESSAGE: #{e.message}"
  end

  def log_http_status(resp)
    @logger.error "ENDPOINT: #{@endpoint} | STATUS: #{resp.response_header.status}"
  end

  def in_github?
    @feed == 'github'
  end

  def in_forums?
    @feed == 'forums'
  end

  def in_disqus?
    @feed == 'disqus'
  end

  def in_blog?
    @feed == 'blog'
  end

  def in_github_issues?
    @feed == 'github' && @enpoint =~ /issues/
  end

  def determine_feed(uri)
    (f = %w(github disqus blog forums).select{|f| uri =~ /#{f}/}) ? f.first : nil;
  end
end
