module Bootable

  def booted?
    @booted
  end

  module RSVPs

    def boot
      @logger.info "Booting #{@feed}."

      http_req = EM::HttpRequest.new(@config.boot_data_url).get({
        query: http_query,
        head: http_head
      })

      http_req.callback {|r| bootstrap(r) }
      http_req.errback {|r| log_http_status(r, :error) }

      self
    end

    def bootstrap(response)
      @config.http_query.merge!({event_id: Yajl::Parser.parse(response.response)})
      @booted = true
    end
  end

end
