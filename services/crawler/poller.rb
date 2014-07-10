require 'core_ext'
require_relative 'decorators/all'
require_relative 'polling_lock'

class Poller
  include Celluloid

  def initialize(brand_name, fetcher, opts = {})
    @brand_name = brand_name
    @fetcher = fetcher
    @decorator = opts.fetch(:decorator) { Decorators::Basic.new }

    interval = opts.fetch(:interval) { 3600 }
    @timer = every(interval) { fetch }
    @lock = PollingLock.new(@brand_name, fetcher_name, interval)
    fetch
  end

  def interval
    @timer.interval
  end

  def interval=(seconds)
    @timer.cancel
    @timer = every(seconds) { fetch }
    @lock.interval = seconds-5
  end

  def fetch
    unless @lock.locked?
      @lock.lock
      if (events = @fetcher.fetch)
        Celluloid.logger.info "#{fetcher_name} for brand '#{@brand_name}', fetched #{events.count} events"
        publish events if events.count > 0
      end
    else
      Celluloid.logger.info "#{fetcher_name} for brand '#{@brand_name}' LOCKED!"
    end
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
