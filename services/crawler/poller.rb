require 'core_ext'
require_relative 'decorators/all'

class Poller
  include Celluloid

  def initialize(path, fetcher, opts = {})
    @path = path
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
        Celluloid.logger.info "#{fetcher_name} for brand '#{@path.brand.name}' LOCKED!"
      else
        locker.lock(lock_name, lock_interval)
        if (events = @fetcher.fetch)
          Celluloid.logger.info "#{fetcher_name} for brand '#{@path.brand.name}', fetched #{events.count} events"
          publish events if events.count > 0
        end
      end
    end
  end

  def publish(data)
    Celluloid.logger.info "Publishing with brand: #{@path.brand}, embed: #{@path.embed}, and service: #{@path.service}"
    publisher.publish @path, data, decorator: @decorator
  end

  def shutyoself
    terminate
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
    "lock:polling:brand/#{@path.brand.id}:embed/#{@path.embed.id}:service/#{@path.service.id}"
  end

  def fetcher_name
    @fetcher.class.name
  end

  def locker
    Celluloid::Actor[:lock_manager]
  end

  def publisher
    Celluloid::Actor[:publisher]
  end
end
