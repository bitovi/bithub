module Bootable

  def booted?
    @booted
  end

  module RSVPs

    def boot
      $logger.info "{BOOTING} #{@feed}."

      http_req = EM::HttpRequest.new(@config.boot_data_url).get({
        query: http_query,
        head: http_head
      })

      http_req.callback {|r| set_query(r) }
      http_req.errback {|r| log_http_status(r, :error) }
      self
    end

    def reboot
      $logger.info "{REBOOTING} #{@feed}"
      @booted = false
      @config.http_query[:event_id] = ""
    end

    def set_query(response)
      begin
        event_ids = Yajl::Parser.parse(response.response)
        @config.http_query.merge!({event_id: event_ids.join(',')})
        @booted = true
        delay(@config.reboot_delay, lambda { reboot })
      rescue Yajl::ParseError => err
        $logger.info "{BOOTING} #{@feed} : Response parse error, web component probably not booted yet."
      end
    end
  end

end
