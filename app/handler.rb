require 'digest/md5'
require 'sanitize'
require 'htmlentities'
require 'rexml/document'
require 'time'

class Handler
  attr_reader :latest
  CUSTOM_RULESET = Sanitize::Config::RELAXED
  CUSTOM_RULESET[:elements] << "div"

  def self.handler(logger, exchange, endpoint)
    new(logger, exchange, endpoint).handler
  end

  def initialize(logger, exchange, endpoint, backlog_size = 100)
    @config = {} # relevant keys: :head, :feed

    @latest = []
    @logger = logger
    @exchange = exchange
    @endpoint = endpoint
    @backlog_size = backlog_size

    yield @config if block_given?
  end

  def handler
    lambda { fetch }
  end

  def fetch
    http_req = EM::HttpRequest.new(@endpoint).get
    # TODO HEAD: ...

    http_req.callback do
      if success?(http_req)
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

  def handle_success(http_req)
    events = Yajl::Parser.parse(http_req.response)

    key_maker = lambda {|e| e[:hash_key] = Digest::MD5.hexdigest(pluck_id(e) + @config[:feed])}
    publish(process(reject_old(events, &key_maker)))
  end

  def reject_old(events, key_maker = nil)
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

  def pluck_id(event_hash = nil)
    (event_hash[:id] || event_hash['id']).to_s
  end
  
  def log_exception(e)
    @logger.error "ENDPOINT: #{@endpoint} | MESSAGE: #{e.message}"
  end

  def log_http_status(resp)
    @logger.error "ENDPOINT: #{@endpoint} | STATUS: #{resp.response_header.status}"
  end
end
