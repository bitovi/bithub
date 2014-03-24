class Poller
  include Celluloid

  def initialize(name, cfg, fetcher_class)
    @feed_name, @endpoint_name = name; @config = cfg
    @fetcher = fetcher_class.new(@config)

    poll
  end

  def poll
    Celluloid.logger.info "Polling #{@feed_name}:#{@endpoint_name}"
    every(x_seconds) { fetch }
  end

  def fetch
    resp = @fetcher.fetch
    Celluloid.logger.info "POLLED #{@feed_name}:#{@endpoint_name} ---> #{resp.length}"
    resp
  end

  private
  def x_seconds
    @config.fetch(:interval) { 60 }
  end
end
