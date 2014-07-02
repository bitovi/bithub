require 'core_ext'
require_relative 'decorators/all'

class Poller
  include Celluloid

  def initialize(brand_name, fetcher, opts = {})
    @brand_name = brand_name
    @fetcher = fetcher
    @decorator = opts.fetch(:decorator) { Decorators::Basic.new }

    interval = opts.fetch(:interval) { 3600 }
    @timer = every(interval) { fetch }
    fetch
  end

  def interval
    @timer.interval
  end

  def interval=(seconds)
    @timer.cancel
    @timer = every(seconds) { fetch }
  end

  def fetch
    events = @fetcher.fetch
    Celluloid.logger.info "Fetching from #{fetcher_name} for brand '#{@brand_name}', fetched #{events.count} events"

    publish events if events.count > 0
  end

  def publish(data)
    Celluloid.logger.info "Publishing with brand: #{@brand_name}, feed: #{feed_name}"
    Celluloid::Actor[:publisher].publish @brand_name, feed_name, data, decorator: @decorator
  end

  def fetcher_name
    @fetcher.class.name
  end

  def feed_name
    fetcher_name.split('::')[1].snake_case
  end

end
