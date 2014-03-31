class Poller
  include Celluloid

  def initialize(opts, client, fetcher_class)
    @fetcher = fetcher_class.new(client, opts)
    @interval = 5
    poll
  end

  def poll
    @timer = every(x_seconds) { fetch }
  end

  def set_interval(seconds)
    @timer.cancel
    @timer = every(seconds) { fetch }
  end

  def fetch
    res = @fetcher.fetch
    Celluloid.logger.info "Fetching from #{@fetcher.class.name}, fetched #{res.count}"
    res
  end

  private
  def x_seconds
    @interval || @fetcher.interval
  end
end
