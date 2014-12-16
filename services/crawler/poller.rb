require 'core_ext'
require_relative 'decorators/all'

class Poller
  include Celluloid
  HEARTBEAT_INTERVAL = 1

  def initialize(path, fetcher, opts = {})
    @path = path
    @fetcher = fetcher
    @decorator = opts.fetch(:decorator) { Decorators::Basic.new }

    @lock_ttl = opts.fetch(:interval) { 3600 }
    @timer = every(HEARTBEAT_INTERVAL) { fetch }
    fetch
  end
  attr_reader :fetcher, :lock_ttl

  def fetch
    if !locker.nil? && !locker.locked?(lock_name)
      locker.lock(lock_name, lock_ttl)
      if (events = @fetcher.fetch)
        Celluloid.logger.info "#{fetcher_name} for brand '#{@path.brand.name}', fetched #{events.count} events"
        publish events if events.count > 0
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
  
  def lock_name
    "lock:polling:brand/#{@path.brand.id}:embed/#{@path.embed.id}:service/#{@path.service.id}"
  end

  def fetcher_name
    @fetcher.class.name
  end

  def locker
    Actor[:lock_manager]
  end

  def publisher
    Actor[:publisher]
  end
end
