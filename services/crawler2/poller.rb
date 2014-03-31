class Poller
  include Celluloid

  def initialize(token, fetcher_class, interval = nil)
    @fetcher = fetcher_class.new(token, config)
    @interval = interval
    poll
  end

  def poll
    Celluloid.logger.info "Polling with #{fetcher_class}"
    @timer = every(x_seconds) { fetch }
  end

  def interval(seconds)
    @timer.cancel
    @timer = every(seconds) { fetch }
  end

  def fetch
    resp = @fetcher.fetch
    Celluloid.logger.info "POLLED with #{fetcher_class} ---> #{resp.length}"
    resp
  end

  private
  def x_seconds
    @interval || @fetcher.default_interval
  end
end
