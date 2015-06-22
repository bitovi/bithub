require 'core_ext'
require 'decorators/all'
require 'types/lock'
require 'services/intervals'

class Poller
  include Celluloid
  include Celluloid::Logger

  def initialize(owner_data, fetcher, opts={})
    @owner_data = owner_data
    @fetcher = fetcher

    # vars used only for testing, usually eval to nil
    if (@env = ENV['ENV']) == 'test'
      @locker = opts[:locker]
      @publisher = opts[:publisher]
      @notifier = opts[:notifier]
    end

    @decorator = opts.fetch(:decorator) { Decorators::Basic.new }
    @lock_ttl = opts.fetch(:interval) { 3600 }

    @timer = every(Intervals::Poller::HEARTBEAT) { poll }

    every(Intervals::ACTOR_MAILBOX_REPORT) do
      info "[POLLER][#{@owner_data.to_log_format}] Mailbox size: #{Actor.current.mailbox.size}"
    end
  end

  def fetch_and_lock
    if lock_manager.available?
      if !lock_manager.locked?(Lock.new(lock_name :initial)) && @fetcher.respond_to?(:initial_fetch)
        lock_manager.lock(Lock.new(lock_name(:initial), :infinity))
        lock_manager.lock(Lock.new(lock_name, @lock_ttl))
        @fetcher.initial_fetch
      elsif !lock_manager.locked?(Lock.new(lock_name))
        lock_manager.lock(Lock.new(lock_name, @lock_ttl))
        @fetcher.fetch
      end
    else
      fail 'LockManager unavailable'
    end
  rescue => e
    error_publisher.publish(e, @owner_data)
    nil
  end

  def poll
    if (events = fetch_and_lock)
      if events.count > 0
        event_publisher.publish(events, @owner_data, decorator: @decorator)
      else
        notification_publisher.publish_to_frontend(empty_response_notif, @owner_data)
      end
      notification_publisher.publish_to_backend(clear_service_errors_notif, @owner_data)
      notification_publisher.publish_to_frontend(clear_service_errors_notif, @owner_data)
    end
  end

  def lock_name(type = :polling)
    if type == :polling
      "lock:polling:brand/#{@owner_data.brand.id}:embed/#{@owner_data.embed.id}:service/#{@owner_data.service.id}"
    elsif type == :initial
      "lock:polling:initial_fetch:brand/#{@owner_data.brand.id}:embed/#{@owner_data.embed.id}:service/#{@owner_data.service.id}"
    end
  end

  def empty_response_notif
    {
      meta: @owner_data.to_h,
      payload: {
        service: {
          id: @owner_data.service.id,
          empty_results: true,
        }
      }
    }
  end

  def clear_service_errors_notif
    {
      meta: @owner_data.to_h,
      payload: {
        service: {
          id: @owner_data.service.id,
          has_errors: false
        }
      }
    }
  end

  def terminate_cascading
    terminate
  end

  def fetcher_name
    @fetcher.class.name
  end

  def lock_manager
    @env != 'test' ? Actor[:lock_manager] : @locker
  end

  def error_publisher
    @env != 'test' ? Actor[:error_publisher] : @publisher
  end

  def event_publisher
    @env != 'test' ? Actor[:event_publisher] : @publisher
  end

  def notification_publisher
    @env != 'test' ? Actor[:notification_publisher] : @notifier
  end
end
