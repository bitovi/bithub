class Poller
  include Celluloid

  def initialize(brand_name, fetcher, opts = {})
    @brand_name = brand_name
    @fetcher = fetcher
    @interval = opts.fetch(:interval) { 3600 }
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
    events = @fetcher.fetch
    Celluloid.logger.info "Fetching from #{@fetcher.class.name}, fetched #{events.count}"
    publish(@brand_name, events)
  end

  def publish(publish, data)
    Celluloid::Actor[:publisher].publish(@brand_name, data)
  end

  private
  def x_seconds
    @interval
  end
end
