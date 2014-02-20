require_relative 'poller'
require_relative 'extensions/bootable'

class RsvpPoller < Poller
  include Loggable

  class Configuration
    attr_accessor :http_query, :http_head,
      :digest_queue_config,
      :processor_config,
      :boot_data_url,
      :reboot_delay
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
    lambda { 
      if booted?
        @logger.info "BOOTED"
        fetch
      else
        @logger.info "NOT BOOTED"
        delay(1, lambda {boot})
      end
    }
  end
    
  def boot
    @logger.info "{BOOTING} #{@feed}."

    http_req = EM::HttpRequest.new(@config.boot_data_url).get({
      query: http_query,
      head: http_head
    })

    http_req.callback {|r| set_query(r) }
    http_req.errback {|r| log_http_status(r, :error) }
    self
  end

  def reboot
    @logger.info "{REBOOTING} #{@feed}"
    @booted = false
    @config.http_query[:event_id] = ""
  end

  def set_query(response)
    begin
      event_ids = Yajl::Parser.parse(response.response)
      @logger.info "IDS: #{event_ids}"
      @config.http_query.merge!({event_id: event_ids.join(',')})
      @booted = true
      delay(@config.reboot_delay, lambda { reboot })
    rescue Yajl::ParseError => err
      @logger.info "{BOOTING} #{@feed} : Response parse error, web component probably not booted yet."
    end
  end

  def booted?
    @booted
  end

end
