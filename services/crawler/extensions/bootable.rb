module Bootable

  def booted?
    @booted
  end

  module RSVPs

    def boot
      @logger.info "{BOOTING} #{@feed}."

      http_req = EM::HttpRequest.new(@config.boot_data_url).get({
        query: http_query,
        head: http_head
      })

      http_req.callback {|r| bootstrap(r) }
      http_req.errback {|r| log_http_status(r, :error) }

      self
    end

    def bootstrap(response)
      begin
        event_ids = Yajl::Parser.parse(response.response)
        @config.http_query.merge!({event_id: event_ids.join(',')})
        @logger.debug "KURAC ====================> #{@config.http_query.inspect}"
        @booted = true
      rescue Yajl::ParseError => err
        @logger.info "{BOOTING} #{@feed} : Response parse error, web component probably not booted yet."
      end
    end
  end

end
