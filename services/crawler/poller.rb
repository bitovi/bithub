require 'core_ext'
require_relative 'error_persistor'
require_relative 'liveservice_notifier'
require_relative 'decorators/all'

class Poller
  include Celluloid
  HEARTBEAT_INTERVAL = 1

  LockInfo = Struct.new(:name, :ttl)

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
    if !locker.nil? && !locker.locked?(LockInfo.new(lock_name, nil))
      locker.lock(LockInfo.new(lock_name, lock_ttl))
      if (events = @fetcher.fetch)
        Celluloid.logger.info "#{fetcher_name} for brand '#{@path.brand.name}', fetched #{events.count} events"
        if events.count > 0
          publish events
        else
          notify_client
        end
      end
    end
  rescue => e
    ErrorPersistor.new(e, @path).persist.notify_client
    Celluloid.logger.error "#{e.class.name} : #{e.message}"
  end

  def publish(data)
    Celluloid.logger.info "Publishing with brand: #{@path.brand}, embed: #{@path.embed}, and service: #{@path.service}"
    publisher.publish @path, data, decorator: @decorator
  end

  def notify_client
    LiveserviceNotifier.new.notif({
      meta: {
        brand_name: @path.brand.name,
        embed_id: @path.embed.id
      },
      payload: {
        service: {
          id: @path.service.id,
          lock_ttl: @lock_ttl,
          empty_results: true,
        }
      }
    }, :services)
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
