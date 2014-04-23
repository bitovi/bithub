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
    Celluloid.logger.info "Fetching from #{fetcher_name} for brand '#{@brand_name}', fetched #{events.count} events"

    publish @brand_name, events
  end

  def publish(publish, data)
    Celluloid.logger.info "Publishing with brand: #{@brand_name}, feed: #{feed_name}"
    Celluloid::Actor[:publisher].publish @brand_name, feed_name, data
  end

  private

  def fetcher_name
    @fetcher.class.name
  end

  def feed_name
    fetcher_name.split('::').second.snake_case
  end

  def x_seconds
    @interval
  end
end
