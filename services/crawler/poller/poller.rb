require 'core_ext'

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
    # Initial fetch crawls back X pages
    if (@fetcher.respond_to?(:initial_fetch)) && (!locker.nil? && !locker.locked?(LockInfo.new(initial_fetch_lock_name)))
      locker.lock(LockInfo.new(initial_fetch_lock_name, :infinity))
      locker.lock(LockInfo.new(lock_name, lock_ttl))
      if (events = @fetcher.initial_fetch)
        handle_new_events(events)
      end
    elsif !locker.nil? && !locker.locked?(LockInfo.new lock_name)
      locker.lock(LockInfo.new(lock_name, lock_ttl))
      if (events = @fetcher.fetch)
        handle_new_events(events)
      end
    end
  rescue => e
    error_publisher.publish(e, @path)
  end

  def handle_new_events(events)
    Celluloid.logger.info "#{fetcher_name} for brand '#{@path.brand.name}', fetched #{events.count} Events"
    if events.count > 0
      publish events
    else
      notification_publisher.publish_to_frontend(empty_response_notif)
    end
    notification_publisher.publish_to_backend(clear_service_errors_notif)
    notification_publisher.publish_to_frontend(clear_service_errors_notif)
  end

  def publish(data)
    Celluloid.logger.info "Publishing with brand: #{@path.brand}, embed: #{@path.embed}, and service: #{@path.service}"
    event_publisher.publish(data, @path, decorator: @decorator)
  end

  def empty_response_notif
    {
      meta: {
        brand_name: @path.brand.name,
        embed_id: @path.embed.id
      },
      payload: {
        service: {
          id: @path.service.id,
          empty_results: true,
        }
      }
    }
  end

  def clear_service_errors_notif
    {
      meta: {
        brand_name: @path.brand.name,
        embed_id: @path.embed.id,
      },
      payload: {
        service: {
          id: @path.service.id,
          has_errors: false
        }
      }
    }
  end


  def terminate_cascading
    terminate
  end

  def lock_name
    "lock:polling:brand/#{@path.brand.id}:embed/#{@path.embed.id}:service/#{@path.service.id}"
  end

  def initial_fetch_lock_name
    "lock:polling:initial_fetch:brand/#{@path.brand.id}:embed/#{@path.embed.id}:service/#{@path.service.id}"
  end

  def fetcher_name
    @fetcher.class.name
  end

  def locker
    Actor[:lock_manager]
  end

  def error_publisher
    Actor[:error_publisher]
  end

  def event_publisher
    Actor[:event_publisher]
  end

  def notification_publisher
    Actor[:notification_publisher]
  end
end
