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
  attr_reader :fetcher

  def fetch
    if not(locker.nil?)
      if locker.locked?(lock_name)
        Celluloid.logger.info "#{fetcher_name} for brand '#{@brand_name}' LOCKED!"
      else
        locker.lock(lock_name, lock_interval)
        if (events = @fetcher.fetch)
          Celluloid.logger.info "#{fetcher_name} for brand '#{@brand_name}', fetched #{events.count} events"
          publish events if events.count > 0
        end
      end
    end
  end

  def publish(data)
    Celluloid.logger.info "Publishing with brand: #{@brand_name}, feed: #{feed_name}"
    publisher.publish @brand_name, feed_name, data, decorator: @decorator
  end
  
  def interval
    @timer.interval
  end

  def lock_interval
    interval - 5
  end

  def interval=(seconds)
    @timer.cancel
    @timer = every(seconds) { fetch }
  end
  
  def lock_name
    ln = fetcher_name.to_s.snake_case.gsub('fetchers','').split('/').reject{|x| x == ""}.join(':') 
    "lock:polling:#{@brand_name}:#{ln}"
  end

  def fetcher_name
    @fetcher.class.name
  end

  def feed_name
    fetcher_name.split('::')[1].snake_case
  end

  def locker
    Celluloid::Actor[:lock_manager]
  end

  def publisher
    Celluloid::Actor[:publisher]
  end
end
