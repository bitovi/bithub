require 'guzzler/redis_api'

class Notifier

  def self.notify_client(about, args)
    new.notify_client(about, args)
  end

  def notify_client(about, args)
    if about == :bit_persisted || about == :bit_moderated
      bit_touched(args.fetch(:bit))
    elsif about == :bit_routed_to_service
      bit_routed_to_service(args.fetch(:service))
    elsif about == :service_error_raised
      service_error_raised(args.fetch(:service_error))
    end
  end

  private

  # Notify client that an bit was updated in some way.
  def bit_touched(bit)
    return if (bit.is_pending? || bit.is_child?)

    bit.hubs.reload.each do |hub|
      Guzzler.lpush('liveservice:bits', Messages.push_bit_to_hub(bit, hub))
      if !bit.is_approved(hub)
        # We don't want to send the whole bit publicly when it is blocked but we need to send just enough so it can be removed from an active hub. This way live hubs (like on event media walls) can be moderated and updated in real-time.
        Guzzler.lpush('liveservice:bits', Messages.pop_bit_from_hub(bit, hub))
      end
    end
  end

  # Notify client that an event was routed to a service so that it can mark it as a loaded service and/or clear the error marker.
  def bit_routed_to_service(service)
    Guzzler.lpush('liveservice:services', Messages.clear_service_errors(service))
  end

  # Notify client that a error was raised while consuming service so that it can mark it as an errored service.
  def service_error_raised(service_error)
    Guzzler.lpush('liveservice:services', Messages.mark_service_as_errored(service_error))
  end

  def empty_response_fetched(service)
  end
end
